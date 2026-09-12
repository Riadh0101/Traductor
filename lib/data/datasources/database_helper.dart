import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _dbName = 'traductor_app.db';
  static const int _dbVersion = 1;

  static const String tableConversations = 'conversations';
  static const String tableMessages = 'messages';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableConversations (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        language1_code TEXT NOT NULL,
        language2_code TEXT NOT NULL,
        title TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMessages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        source_language_code TEXT NOT NULL,
        source_text TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES $tableConversations (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
