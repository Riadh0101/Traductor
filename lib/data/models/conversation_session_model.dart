import '../../core/constants/supported_languages.dart';
import '../../domain/entities/conversation_session.dart';
import '../../domain/entities/translation_message.dart';

class ConversationSessionModel extends ConversationSession {
  const ConversationSessionModel({
    required super.id,
    required super.createdAt,
    required super.language1,
    required super.language2,
    required super.title,
    super.messages,
  });

  factory ConversationSessionModel.fromEntity(ConversationSession session) {
    return ConversationSessionModel(
      id: session.id,
      createdAt: session.createdAt,
      language1: session.language1,
      language2: session.language2,
      title: session.title,
      messages: session.messages,
    );
  }

  factory ConversationSessionModel.fromMap(
    Map<String, dynamic> map, [
    List<TranslationMessage> messages = const [],
  ]) {
    return ConversationSessionModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      language1: SupportedLanguages.fromIsoCode(map['language1_code'] as String),
      language2: SupportedLanguages.fromIsoCode(map['language2_code'] as String),
      title: map['title'] as String,
      messages: messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'language1_code': language1.isoCode,
      'language2_code': language2.isoCode,
      'title': title,
    };
  }
}
