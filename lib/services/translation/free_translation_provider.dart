import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/failures.dart';
import 'translation_provider.dart';

class FreeTranslationProvider implements TranslationProvider {
  final http.Client _client;

  FreeTranslationProvider([http.Client? client])
      : _client = client ?? http.Client();

  @override
  String get id => 'free_default';

  @override
  String get name => 'Free High-Speed Translation Engine';

  @override
  bool get requiresApiKey => false;

  @override
  bool get requiresApiUrl => false;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final cleanText = request.text.trim();
    if (cleanText.isEmpty) {
      return TranslationResult(
        translatedText: '',
        providerName: name,
      );
    }

    // 1. Try Google GTX Web API (Fastest & most accurate free endpoint)
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=${request.sourceLanguage}&tl=${request.targetLanguage}&dt=t&q=${Uri.encodeComponent(cleanText)}',
      );
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0] is List) {
          final buffer = StringBuffer();
          for (final item in data[0] as List) {
            if (item is List && item.isNotEmpty && item[0] != null) {
              buffer.write(item[0].toString());
            }
          }
          final resultText = buffer.toString().trim();
          if (resultText.isNotEmpty) {
            return TranslationResult(
              translatedText: resultText,
              providerName: 'Google Free Engine',
            );
          }
        }
      }
    } catch (_) {
      // Fall through to MyMemory
    }

    // 2. Try MyMemory API
    try {
      final langPair = '${request.sourceLanguage}|${request.targetLanguage}';
      final uri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(cleanText)}&langpair=$langPair',
      );

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final responseData = data['responseData'] as Map<String, dynamic>?;
        final translatedText = responseData?['translatedText'] as String?;

        if (translatedText != null && translatedText.isNotEmpty) {
          final unescaped = _unescapeHtml(translatedText);
          return TranslationResult(
            translatedText: unescaped,
            providerName: 'MyMemory Free Engine',
          );
        }
      }
    } catch (_) {
      // Fall through to Lingva
    }

    // 3. Fallback: Lingva Translate public API
    try {
      final uri = Uri.parse(
        'https://lingva.ml/api/v1/${request.sourceLanguage}/${request.targetLanguage}/${Uri.encodeComponent(cleanText)}',
      );
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translation = data['translation'] as String?;
        if (translation != null && translation.isNotEmpty) {
          return TranslationResult(
            translatedText: translation,
            providerName: 'Lingva Public Engine',
          );
        }
      }
    } catch (_) {
      // Fall through to error
    }

    throw const TranslationFailure('Translation service is currently unavailable. Please check your network connection.');
  }

  String _unescapeHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
