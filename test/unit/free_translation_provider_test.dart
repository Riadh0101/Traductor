import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:traductor/core/errors/failures.dart';
import 'package:traductor/services/translation/free_translation_provider.dart';
import 'package:traductor/services/translation/translation_provider.dart';

void main() {
  group('FreeTranslationProvider Tests', () {
    test('returns empty text directly for empty request', () async {
      final provider = FreeTranslationProvider();
      final result = await provider.translate(
        const TranslationRequest(
          text: '   ',
          sourceLanguage: 'ar',
          targetLanguage: 'tr',
        ),
      );

      expect(result.translatedText, '');
    });

    test('successfully translates via Google GTX engine format', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'translate.googleapis.com') {
          // Google GTX JSON response format: [[["Merhaba dünya","Hello world",null,null,1]],null,"en"]
          final body = jsonEncode([
            [
              ['Merhaba dunya', 'Hello world', null, null, 1]
            ],
            null,
            'en',
          ]);
          return http.Response(body, 200);
        }
        return http.Response('Not Found', 404);
      });

      final provider = FreeTranslationProvider(mockClient);
      final result = await provider.translate(
        const TranslationRequest(
          text: 'Hello world',
          sourceLanguage: 'en',
          targetLanguage: 'tr',
        ),
      );

      expect(result.translatedText, 'Merhaba dunya');
      expect(result.providerName, 'Google Free Engine');
    });

    test('falls back to MyMemory when Google GTX fails and unescapes HTML', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'translate.googleapis.com') {
          return http.Response('Error', 500);
        }
        if (request.url.host == 'api.mymemory.translated.net') {
          final body = jsonEncode({
            'responseData': {
              'translatedText': 'It&#39;s a &quot;great&quot; day &amp; sunny',
            },
          });
          return http.Response(body, 200);
        }
        return http.Response('Not Found', 404);
      });

      final provider = FreeTranslationProvider(mockClient);
      final result = await provider.translate(
        const TranslationRequest(
          text: 'It is a great day and sunny',
          sourceLanguage: 'en',
          targetLanguage: 'en',
        ),
      );

      expect(result.translatedText, 'It\'s a "great" day & sunny');
      expect(result.providerName, 'MyMemory Free Engine');
    });

    test('falls back to Lingva when Google GTX and MyMemory fail', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'translate.googleapis.com' ||
            request.url.host == 'api.mymemory.translated.net') {
          return http.Response('Rate limited', 429);
        }
        if (request.url.host == 'lingva.ml') {
          final body = jsonEncode({
            'translation': 'Lingva Translated Text',
          });
          return http.Response(body, 200);
        }
        return http.Response('Not Found', 404);
      });

      final provider = FreeTranslationProvider(mockClient);
      final result = await provider.translate(
        const TranslationRequest(
          text: 'Source text',
          sourceLanguage: 'en',
          targetLanguage: 'tr',
        ),
      );

      expect(result.translatedText, 'Lingva Translated Text');
      expect(result.providerName, 'Lingva Public Engine');
    });

    test('throws TranslationFailure when all translation tiers fail', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Service down', 500);
      });

      final provider = FreeTranslationProvider(mockClient);

      expect(
        () => provider.translate(
          const TranslationRequest(
            text: 'Test',
            sourceLanguage: 'en',
            targetLanguage: 'tr',
          ),
        ),
        throwsA(isA<TranslationFailure>()),
      );
    });
  });
}
