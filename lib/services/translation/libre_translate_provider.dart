import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/failures.dart';
import 'translation_provider.dart';

class LibreTranslateProvider implements TranslationProvider {
  final http.Client _client;

  LibreTranslateProvider([http.Client? client])
      : _client = client ?? http.Client();

  @override
  String get id => 'libre_translate';

  @override
  String get name => 'LibreTranslate (Self-hosted or Public)';

  @override
  bool get requiresApiKey => false;

  @override
  bool get requiresApiUrl => true;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final apiUrl = request.apiUrl?.trim();
    if (apiUrl == null || apiUrl.isEmpty) {
      throw const TranslationFailure('LibreTranslate API URL is required in Settings.');
    }

    try {
      final endpoint = apiUrl.endsWith('/') ? '${apiUrl}translate' : '$apiUrl/translate';
      final uri = Uri.parse(endpoint);

      final headers = {'Content-Type': 'application/json'};
      if (request.apiKey != null && request.apiKey!.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${request.apiKey!.trim()}';
      }

      final body = jsonEncode({
        'q': request.text,
        'source': request.sourceLanguage,
        'target': request.targetLanguage,
        'format': 'text',
        if (request.apiKey != null && request.apiKey!.trim().isNotEmpty)
          'api_key': request.apiKey!.trim(),
      });

      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translatedText = data['translatedText'] as String?;
        if (translatedText != null) {
          return TranslationResult(
            translatedText: translatedText,
            providerName: name,
          );
        }
      }

      throw TranslationFailure('LibreTranslate server responded with status: ${response.statusCode}');
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw TranslationFailure('LibreTranslate error: $e', e);
    }
  }
}
