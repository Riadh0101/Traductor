import 'language.dart';
import 'translation_message.dart';

class ConversationSession {
  final String id;
  final DateTime createdAt;
  final Language language1;
  final Language language2;
  final String title;
  final List<TranslationMessage> messages;

  const ConversationSession({
    required this.id,
    required this.createdAt,
    required this.language1,
    required this.language2,
    required this.title,
    this.messages = const [],
  });

  ConversationSession copyWith({
    String? id,
    DateTime? createdAt,
    Language? language1,
    Language? language2,
    String? title,
    List<TranslationMessage>? messages,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      language1: language1 ?? this.language1,
      language2: language2 ?? this.language2,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }
}
