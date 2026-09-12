import 'package:sqflite/sqflite.dart';
import '../../domain/entities/conversation_session.dart';
import '../../domain/entities/translation_message.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/database_helper.dart';
import '../models/conversation_session_model.dart';
import '../models/translation_message_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  Future<Database> get _db async => await DatabaseHelper.database;

  @override
  Future<List<ConversationSession>> getAllSessions() async {
    final db = await _db;
    final sessionMaps = await db.query(
      DatabaseHelper.tableConversations,
      orderBy: 'created_at DESC',
    );

    final List<ConversationSession> sessions = [];

    for (final map in sessionMaps) {
      final sessionId = map['id'] as String;
      final messageMaps = await db.query(
        DatabaseHelper.tableMessages,
        where: 'conversation_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp ASC',
      );

      final messages = messageMaps
          .map((m) => TranslationMessageModel.fromMap(m))
          .toList();

      sessions.add(ConversationSessionModel.fromMap(map, messages));
    }

    return sessions;
  }

  @override
  Future<ConversationSession?> getSessionById(String id) async {
    final db = await _db;
    final sessionMaps = await db.query(
      DatabaseHelper.tableConversations,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (sessionMaps.isEmpty) return null;

    final messageMaps = await db.query(
      DatabaseHelper.tableMessages,
      where: 'conversation_id = ?',
      whereArgs: [id],
      orderBy: 'timestamp ASC',
    );

    final messages = messageMaps
        .map((m) => TranslationMessageModel.fromMap(m))
        .toList();

    return ConversationSessionModel.fromMap(sessionMaps.first, messages);
  }

  @override
  Future<void> saveSession(ConversationSession session) async {
    final db = await _db;
    final model = ConversationSessionModel.fromEntity(session);
    await db.insert(
      DatabaseHelper.tableConversations,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> addMessage(TranslationMessage message) async {
    final db = await _db;
    final model = TranslationMessageModel.fromEntity(message);
    await db.insert(
      DatabaseHelper.tableMessages,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSession(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseHelper.tableMessages,
      where: 'conversation_id = ?',
      whereArgs: [id],
    );
    await db.delete(
      DatabaseHelper.tableConversations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAllHistory() async {
    final db = await _db;
    await db.delete(DatabaseHelper.tableMessages);
    await db.delete(DatabaseHelper.tableConversations);
  }
}
