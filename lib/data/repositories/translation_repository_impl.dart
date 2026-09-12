import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/language.dart';
import '../../domain/repositories/translation_repository.dart';
import '../../services/translation/ai_translation_provider.dart';
import '../../services/translation/free_translation_provider.dart';
import '../../services/translation/libre_translate_provider.dart';
import '../../services/translation/translation_provider.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final NetworkInfo _networkInfo;
  final Map<String, TranslationProvider> _providers = {};
  final Map<String, String> _cache = {}; // "src:tgt:text" -> translatedText

  TranslationRepositoryImpl({
    NetworkInfo? networkInfo,
    Map<String, TranslationProvider>? customProviders,
  }) : _networkInfo = networkInfo ?? NetworkInfoImpl() {
    if (customProviders != null) {
      _providers.addAll(customProviders);
    } else {
      _registerDefaultProviders();
    }
  }

  void _registerDefaultProviders() {
    final free = FreeTranslationProvider();
    final libre = LibreTranslateProvider();
    final openai = AiTranslationProvider(isGemini: false);
    final gemini = AiTranslationProvider(isGemini: true);

    _providers[free.id] = free;
    _providers[libre.id] = libre;
    _providers[openai.id] = openai;
    _providers[gemini.id] = gemini;
  }

  @override
  Future<String> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
    String? preferredProvider,
    String? apiUrl,
    String? apiKey,
  }) async {
    final result = await translateDetailed(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      preferredProvider: preferredProvider,
      apiUrl: apiUrl,
      apiKey: apiKey,
    );
    return result.translatedText;
  }

  @override
  Future<TranslationResult> translateDetailed({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
    String? preferredProvider,
    String? apiUrl,
    String? apiKey,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return const TranslationResult(
        translatedText: '',
        providerName: 'None',
        cleanedSourceText: '',
      );
    }

    // Same language check
    if (sourceLanguage.isoCode == targetLanguage.isoCode) {
      return TranslationResult(
        translatedText: cleanText,
        providerName: 'Identical',
        cleanedSourceText: cleanText,
      );
    }

    // Cache check
    final cacheKey = '${sourceLanguage.isoCode}:${targetLanguage.isoCode}:$cleanText';
    if (_cache.containsKey(cacheKey)) {
      return TranslationResult(
        translatedText: _cache[cacheKey]!,
        providerName: 'Cache',
        isFromCache: true,
      );
    }

    // Network connectivity check (Requirement 18: clearly report internet requirement)
    final hasInternet = await _networkInfo.isConnected;
    if (!hasInternet) {
      throw const NetworkFailure(
        'Internet connection required for real-time translation. Please check your network connection.',
      );
    }

    // Select provider (defaults to Gemini AI with intelligent speech sifting)
    final defaultId = _providers.containsKey(AppConstants.defaultTranslationProvider)
        ? AppConstants.defaultTranslationProvider
        : (_providers.isNotEmpty ? _providers.keys.first : AppConstants.providerFree);

    final providerId = (preferredProvider != null && preferredProvider.isNotEmpty)
        ? preferredProvider
        : defaultId;
    final provider = _providers[providerId] ?? _providers.values.first;

    final resolvedApiKey = (apiKey != null && apiKey.trim().isNotEmpty)
        ? apiKey.trim()
        : (providerId == AppConstants.providerGemini ? AppConstants.defaultGeminiApiKey : null);

    final request = TranslationRequest(
      text: cleanText,
      sourceLanguage: sourceLanguage.isoCode,
      targetLanguage: targetLanguage.isoCode,
      apiUrl: apiUrl,
      apiKey: resolvedApiKey,
    );

    try {
      final result = await provider.translate(request);
      _cache[cacheKey] = result.translatedText;
      return result;
    } catch (e) {
      // Automatic robust fallback to FreeTranslationProvider if primary engine fails
      if (providerId != AppConstants.providerFree) {
        try {
          final fallbackProvider = _providers[AppConstants.providerFree]!;
          final fallbackResult = await fallbackProvider.translate(request);
          _cache[cacheKey] = fallbackResult.translatedText;
          return fallbackResult;
        } catch (_) {
          // rethrow original failure below
        }
      }
      rethrow;
    }
  }
}
