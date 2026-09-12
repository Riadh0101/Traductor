import 'language.dart';

class TranslationMessage {
  final String id;
  final String conversationId;
  final Language sourceLanguage;
  final String sourceText;
  final Language targetLanguage;
  final String translatedText;
  final DateTime timestamp;

  const TranslationMessage({
    required this.id,
    required this.conversationId,
    required this.sourceLanguage,
    required this.sourceText,
    required this.targetLanguage,
    required this.translatedText,
    required this.timestamp,
  });

  TranslationMessage copyWith({
    String? id,
    String? conversationId,
    Language? sourceLanguage,
    String? sourceText,
    Language? targetLanguage,
    String? translatedText,
    DateTime? timestamp,
  }) {
    return TranslationMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      sourceText: sourceText ?? this.sourceText,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      translatedText: translatedText ?? this.translatedText,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
