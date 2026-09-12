import 'package:flutter_test/flutter_test.dart';
import 'package:traductor/core/constants/supported_languages.dart';
import 'package:traductor/domain/entities/translation_message.dart';
import 'package:traductor/features/phrasebook/data/travel_phrases_data.dart';
import 'package:traductor/services/translation/ai_translation_provider.dart';

void main() {
  group('TravelPhrasesData Tests', () {
    test('contains expected travel categories and valid bilingual phrases', () {
      final categories = TravelPhrasesData.categories;
      expect(categories.length, greaterThanOrEqualTo(7));

      for (final cat in categories) {
        expect(cat.title.isNotEmpty, true);
        expect(cat.titleArabic.isNotEmpty, true);
        expect(cat.emoji.isNotEmpty, true);
        expect(cat.phrases.isNotEmpty, true);

        for (final phrase in cat.phrases) {
          expect(phrase.english.isNotEmpty, true);
          expect(phrase.arabic.isNotEmpty, true);
        }
      }
    });

    test('specific categories are correctly defined', () {
      final titles = TravelPhrasesData.categories.map((c) => c.title).toList();
      expect(titles.contains('Airport & Transit'), true);
      expect(titles.contains('Hotel & Stay'), true);
      expect(titles.contains('Transport & Directions'), true);
      expect(titles.contains('Medical & Emergency'), true);
    });
  });

  group('AI Conversation Summary Tests', () {
    late AiTranslationProvider aiProvider;

    setUp(() {
      aiProvider = AiTranslationProvider(isGemini: true);
    });

    test('returns notice when messages list is empty', () async {
      final summary = await aiProvider.summarizeConversation(
        messages: [],
        summaryLanguageCode: 'ar',
        apiKey: 'dummy_key',
      );

      expect(summary, 'No messages to summarize.');
    });

    test('returns structured summary fallback when offline/dummy key', () async {
      final testMessages = [
        TranslationMessage(
          id: '1',
          conversationId: 'c1',
          sourceLanguage: SupportedLanguages.arabic,
          sourceText: 'مرحباً، أين الفندق؟',
          targetLanguage: SupportedLanguages.turkish,
          translatedText: 'Merhaba, otel nerede?',
          timestamp: DateTime(2026, 9, 12, 10, 0),
        ),
        TranslationMessage(
          id: '2',
          conversationId: 'c1',
          sourceLanguage: SupportedLanguages.turkish,
          sourceText: 'Şurada, sağ tarafta.',
          targetLanguage: SupportedLanguages.arabic,
          translatedText: 'هناك، على الجانب الأيمن.',
          timestamp: DateTime(2026, 9, 12, 10, 2),
        ),
      ];

      final summary = await aiProvider.summarizeConversation(
        messages: testMessages,
        summaryLanguageCode: 'ar',
        apiKey: 'dummy_key',
      );

      expect(summary.isNotEmpty, true);
      expect(summary.contains('2') || summary.contains('Overview') || summary.contains('Arabic'), true);
    });
  });
}
