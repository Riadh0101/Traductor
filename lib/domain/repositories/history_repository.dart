import '../entities/conversation_session.dart';
import '../entities/translation_message.dart';

abstract class HistoryRepository {
  Future<List<ConversationSession>> getAllSessions();
  Future<ConversationSession?> getSessionById(String id);
  Future<void> saveSession(ConversationSession session);
  Future<void> addMessage(TranslationMessage message);
  Future<void> deleteSession(String id);
  Future<void> clearAllHistory();
}
