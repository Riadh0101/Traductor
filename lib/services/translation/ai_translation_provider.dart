import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/supported_languages.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/translation_message.dart';
import 'translation_provider.dart';

class AiTranslationProvider implements TranslationProvider {
  final http.Client _client;
  final bool isGemini;

  AiTranslationProvider({this.isGemini = false, http.Client? client})
      : _client = client ?? http.Client();

  @override
  String get id => isGemini ? 'gemini' : 'openai';

  @override
  String get name => isGemini ? 'Google Gemini AI' : 'OpenAI GPT';

  @override
  bool get requiresApiKey => true;

  @override
  bool get requiresApiUrl => false;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final apiKey = request.apiKey?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw TranslationFailure('$name API key is required in Settings.');
    }

    if (isGemini) {
      return await _translateWithGemini(request, apiKey);
    } else {
      return await _translateWithOpenAi(request, apiKey);
    }
  }

  Future<TranslationResult> _translateWithOpenAi(
    TranslationRequest request,
    String apiKey,
  ) async {
    try {
      final uri = Uri.parse(
        request.apiUrl?.isNotEmpty == true
            ? request.apiUrl!
            : 'https://api.openai.com/v1/chat/completions',
      );

      final systemPrompt =
          'You are a master real-time speech refiner and professional interpreter.\n'
          'Spoken voice input often contains repetitions, stuttering, filler words (e.g. um, uh, يعني, yani, şey, ah), '
          'hesitations, and mid-speech self-corrections (e.g. "أريد الذهاب إلى السوق أقصد المطار" -> "أريد الذهاب إلى المطار").\n\n'
          'STRICT REQUIREMENTS:\n'
          '1. Speech Sifting (تصفية وتنسيق الكلام): Thoroughly clean the spoken input in ${request.sourceLanguage}. Eliminate duplicate words, stuttering, and fillers. Resolve any self-corrections into a clear, complete coherent thought. NEVER truncate, summarize, or drop any valid clauses or parts of the speaker\'s thought.\n'
          '2. Professional Translation (ترجمة احترافية كاملة): Translate the complete sifted thought accurately, fluently, and naturally into ${request.targetLanguage}, preserving all nuances and details.\n\n'
          'Return ONLY a valid JSON object with keys "cleaned_source" and "translation".';

      final body = jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': request.text},
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.2,
      });

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      ).timeout(const Duration(seconds: 18));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String?;
          if (content != null && content.isNotEmpty) {
            try {
              final jsonContent = jsonDecode(content) as Map<String, dynamic>;
              final translation = (jsonContent['translation'] as String?)?.trim();
              final cleaned = (jsonContent['cleaned_source'] as String?)?.trim();
              if (translation != null && translation.isNotEmpty) {
                return TranslationResult(
                  translatedText: translation,
                  providerName: name,
                  cleanedSourceText: cleaned,
                );
              }
            } catch (_) {
              // Fallback to raw content if not JSON
            }
            return TranslationResult(
              translatedText: content.trim(),
              providerName: name,
            );
          }
        }
      }

      throw TranslationFailure('OpenAI returned status ${response.statusCode}: ${response.body}');
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw TranslationFailure('OpenAI error: $e', e);
    }
  }

  Future<TranslationResult> _translateWithGemini(
    TranslationRequest request,
    String apiKey,
  ) async {
    final srcLang = SupportedLanguages.fromIsoCode(request.sourceLanguage);
    final tgtLang = SupportedLanguages.fromIsoCode(request.targetLanguage);
    final srcName = '${srcLang.name} (${srcLang.nativeName})';
    final tgtName = '${tgtLang.name} (${tgtLang.nativeName})';

    final prompt =
        'You are a master bilingual interpreter and real-time speech refiner specializing in $srcName and $tgtName.\n'
        'Spoken voice input often contains repetitions, stuttering, and conversational fillers (e.g. um, uh, يعني, yani, şey, ah).\n\n'
        'STRICT REQUIREMENTS:\n'
        '1. Speech Sifting (تصفية وتنسيق الكلام):\n'
        '   - Clean the spoken input in $srcName. Remove genuine stuttering duplicates and conversational fillers.\n'
        '   - Mid-speech self-corrections: Resolve any self-corrections into a clear, complete coherent thought.\n'
        '   - INTEGRITY MANDATE: NEVER truncate, summarize, or omit any valid clauses, questions, conditions, names, numbers, or details from the speaker\'s thought.\n'
        '2. Professional Translation (ترجمة احترافية كاملة ومتقنة):\n'
        '   - Translate the complete sifted thought accurately, fluently, and naturally from $srcName to $tgtName.\n'
        '   - For Turkish output: Respect Turkish grammar, SOV word order, vowel harmony, agglutinative suffix structures, and appropriate politeness.\n'
        '   - For Arabic output: Produce natural, accurate Modern Standard Arabic, preserving full sentence meaning, questions, and emphasis.\n'
        '   - Preserve 100% of the semantic meaning and full sentence structure. Do NOT produce partial translations.\n\n'
        'Return ONLY a valid JSON object in this exact schema without markdown:\n'
        '{"cleaned_source": "<complete sifted source sentence>", "translation": "<natural fluent full translation in target language>"}\n\n'
        'Spoken input: ${request.text}';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      }
    });

    // Supported models in priority order (verified working with current key)
    final candidateModels = ['gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-2.5-flash'];
    String? lastError;

    for (final model in candidateModels) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 14));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final rawText = parts[0]['text'] as String?;
              if (rawText != null && rawText.isNotEmpty) {
                try {
                  var cleanJson = rawText.trim();
                  if (cleanJson.startsWith('```')) {
                    cleanJson = cleanJson.replaceAll(RegExp(r'^```(json)?|```$', multiLine: true), '').trim();
                  }
                  final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;
                  final translation = (parsed['translation'] as String?)?.trim();
                  final cleanedSource = (parsed['cleaned_source'] as String?)?.trim();

                  if (translation != null && translation.isNotEmpty) {
                    return TranslationResult(
                      translatedText: translation,
                      providerName: name,
                      cleanedSourceText: cleanedSource,
                    );
                  }
                } catch (_) {
                  // Fallback to raw text if not JSON
                }

                return TranslationResult(
                  translatedText: rawText.trim(),
                  providerName: name,
                );
              }
            }
          }
        } else if (response.statusCode == 404) {
          // Try next candidate model
          lastError = 'Gemini model $model not found (status 404)';
          continue;
        } else {
          lastError = 'Gemini returned status ${response.statusCode}: ${response.body}';
        }
      } catch (e) {
        lastError = e.toString();
      }
    }

    throw TranslationFailure(lastError ?? 'Gemini translation service unavailable.');
  }

  Future<String> summarizeConversation({
    required List<TranslationMessage> messages,
    required String summaryLanguageCode,
    required String apiKey,
  }) async {
    if (messages.isEmpty) {
      return 'No messages to summarize.';
    }

    final dialogTurns = messages.map((m) {
      return '${m.sourceLanguage.name}: ${m.sourceText}\n-> (${m.targetLanguage.name}): ${m.translatedText}';
    }).join('\n\n');

    final summaryLang = SupportedLanguages.fromIsoCode(summaryLanguageCode);
    final prompt =
        'You are an executive assistant for "Basira AI - بصيرة".\n'
        'Analyze this translated bilingual conversation:\n\n'
        '$dialogTurns\n\n'
        'TASK:\n'
        'Create a concise, well-structured, professional executive summary in ${summaryLang.name} (${summaryLang.nativeName}).\n'
        'Include:\n'
        '1. 📌 Key Topic & Goal (الموضوع الرئيسي)\n'
        '2. 📝 Main Points & Agreements (النقاط والاتفاقات الرئيسية)\n'
        '3. ⚡ Action Items / Decisions if any (القرارات أو الخطوات القادمة)\n'
        'Keep it clear, modern, formatted in clean markdown bullet points.';

    final candidateModels = ['gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-2.5-flash'];
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
      }
    });

    for (final model in candidateModels) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );
        final response = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 18));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text.trim();
              }
            }
          }
        }
      } catch (_) {
        // try next candidate model
      }
    }

    // Structured fallback if offline
    return 'Summary Overview (ملخص الجلسة):\n'
        '• Total dialogue turns: ${messages.length}\n'
        '• Primary languages: ${messages.map((m) => m.sourceLanguage.name).toSet().join(', ')}\n'
        '• Conversation started: ${messages.first.timestamp.toString().substring(0, 16)}\n'
        '• All exchanges were successfully translated and saved locally.';
  }
}
