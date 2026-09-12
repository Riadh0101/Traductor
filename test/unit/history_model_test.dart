import 'package:flutter_test/flutter_test.dart';
import 'package:traductor/core/constants/supported_languages.dart';
import 'package:traductor/data/models/conversation_session_model.dart';
import 'package:traductor/data/models/translation_message_model.dart';
import 'package:traductor/domain/entities/conversation_session.dart';
import 'package:traductor/domain/entities/translation_message.dart';

void main() {
  group('History Models Serialization Tests', () {
    test('TranslationMessageModel converts to/from Map correctly', () {
      final now = DateTime(2026, 9, 5, 12, 0, 0);
      final message = TranslationMessage(
        id: 'msg-1',
        conversationId: 'conv-1',
        sourceLanguage: SupportedLanguages.arabic,
        sourceText: 'مرحبا',
        targetLanguage: SupportedLanguages.turkish,
        translatedText: 'Merhaba',
        timestamp: now,
      );

      final model = TranslationMessageModel.fromEntity(message);
      final map = model.toMap();

      expect(map['id'], 'msg-1');
      expect(map['conversation_id'], 'conv-1');
      expect(map['source_language_code'], 'ar');
      expect(map['source_text'], 'مرحبا');
      expect(map['target_language_code'], 'tr');
      expect(map['translated_text'], 'Merhaba');
      expect(map['timestamp'], now.toIso8601String());

      final reconstructed = TranslationMessageModel.fromMap(map);
      expect(reconstructed.id, message.id);
      expect(reconstructed.conversationId, message.conversationId);
      expect(reconstructed.sourceLanguage.isoCode, 'ar');
      expect(reconstructed.targetLanguage.isoCode, 'tr');
      expect(reconstructed.sourceText, 'مرحبا');
      expect(reconstructed.translatedText, 'Merhaba');
      expect(reconstructed.timestamp, now);
    });

    test('ConversationSessionModel converts to/from Map correctly', () {
      final now = DateTime(2026, 9, 5, 12, 0, 0);
      final session = ConversationSession(
        id: 'conv-1',
        createdAt: now,
        language1: SupportedLanguages.arabic,
        language2: SupportedLanguages.turkish,
        title: 'Arabic ⇄ Turkish',
        messages: const [],
      );

      final model = ConversationSessionModel.fromEntity(session);
      final map = model.toMap();

      expect(map['id'], 'conv-1');
      expect(map['created_at'], now.toIso8601String());
      expect(map['language1_code'], 'ar');
      expect(map['language2_code'], 'tr');
      expect(map['title'], 'Arabic ⇄ Turkish');

      final reconstructed = ConversationSessionModel.fromMap(map, []);
      expect(reconstructed.id, session.id);
      expect(reconstructed.language1.isoCode, 'ar');
      expect(reconstructed.language2.isoCode, 'tr');
      expect(reconstructed.title, session.title);
      expect(reconstructed.createdAt, now);
    });
  });
}
