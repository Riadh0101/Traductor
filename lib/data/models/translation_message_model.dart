import '../../core/constants/supported_languages.dart';
import '../../domain/entities/translation_message.dart';

class TranslationMessageModel extends TranslationMessage {
  const TranslationMessageModel({
    required super.id,
    required super.conversationId,
    required super.sourceLanguage,
    required super.sourceText,
    required super.targetLanguage,
    required super.translatedText,
    required super.timestamp,
  });

  factory TranslationMessageModel.fromEntity(TranslationMessage message) {
    return TranslationMessageModel(
      id: message.id,
      conversationId: message.conversationId,
      sourceLanguage: message.sourceLanguage,
      sourceText: message.sourceText,
      targetLanguage: message.targetLanguage,
      translatedText: message.translatedText,
      timestamp: message.timestamp,
    );
  }

  factory TranslationMessageModel.fromMap(Map<String, dynamic> map) {
    return TranslationMessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      sourceLanguage: SupportedLanguages.fromIsoCode(map['source_language_code'] as String),
      sourceText: map['source_text'] as String,
      targetLanguage: SupportedLanguages.fromIsoCode(map['target_language_code'] as String),
      translatedText: map['translated_text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'source_language_code': sourceLanguage.isoCode,
      'source_text': sourceText,
      'target_language_code': targetLanguage.isoCode,
      'translated_text': translatedText,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
