import 'package:flutter_test/flutter_test.dart';
import 'package:traductor/core/constants/supported_languages.dart';
import 'package:traductor/core/network/network_info.dart';
import 'package:traductor/data/repositories/translation_repository_impl.dart';
import 'package:traductor/services/translation/translation_provider.dart';

class MockNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(connected);
}

class MockTranslationProvider implements TranslationProvider {
  @override
  String get id => 'free_default';

  @override
  String get name => 'Mock Engine';

  @override
  bool get requiresApiKey => false;

  @override
  bool get requiresApiUrl => false;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    return TranslationResult(
      translatedText: 'Mocked translation of ${request.text}',
      providerName: name,
    );
  }
}

void main() {
  group('TranslationRepository Tests', () {
    late MockNetworkInfo mockNetwork;
    late MockTranslationProvider mockProvider;
    late TranslationRepositoryImpl repository;

    setUp(() {
      mockNetwork = MockNetworkInfo();
      mockProvider = MockTranslationProvider();
      repository = TranslationRepositoryImpl(
        networkInfo: mockNetwork,
        customProviders: {mockProvider.id: mockProvider},
      );
    });

    test('translates text using provider when network is available', () async {
      final result = await repository.translate(
        text: 'مرحبا',
        sourceLanguage: SupportedLanguages.arabic,
        targetLanguage: SupportedLanguages.turkish,
      );

      expect(result, 'Mocked translation of مرحبا');
    });

    test('returns same text when source and target language are identical', () async {
      final result = await repository.translate(
        text: 'Hello world',
        sourceLanguage: SupportedLanguages.english,
        targetLanguage: SupportedLanguages.english,
      );

      expect(result, 'Hello world');
    });

    test('retrieves subsequent identical translations from cache', () async {
      final res1 = await repository.translate(
        text: 'Good morning',
        sourceLanguage: SupportedLanguages.english,
        targetLanguage: SupportedLanguages.arabic,
      );

      // Even if network goes down, cached translation is returned
      mockNetwork.connected = false;

      final res2 = await repository.translate(
        text: 'Good morning',
        sourceLanguage: SupportedLanguages.english,
        targetLanguage: SupportedLanguages.arabic,
      );

      expect(res1, res2);
    });
  });
}
