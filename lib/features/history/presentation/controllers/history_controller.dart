import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/history_repository_impl.dart';
import '../../../../domain/entities/conversation_session.dart';
import '../../../../domain/entities/translation_message.dart';
import '../../../../domain/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl();
});

final historyControllerProvider =
    StateNotifierProvider<HistoryController, AsyncValue<List<ConversationSession>>>(
  (ref) {
    final repo = ref.watch(historyRepositoryProvider);
    return HistoryController(repo);
  },
);

class HistoryController extends StateNotifier<AsyncValue<List<ConversationSession>>> {
  final HistoryRepository _repository;

  HistoryController(this._repository) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final sessions = await _repository.getAllSessions();
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveSession(ConversationSession session) async {
    try {
      await _repository.saveSession(session);
      await loadSessions();
    } catch (e) {
      // Non-fatal logging
    }
  }

  Future<void> addMessage(TranslationMessage message) async {
    try {
      await _repository.addMessage(message);
      await loadSessions();
    } catch (e) {
      // Non-fatal logging
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _repository.deleteSession(id);
      await loadSessions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await _repository.clearAllHistory();
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
