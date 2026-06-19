import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'p2p_chat.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE peers (
        id TEXT PRIMARY KEY,
        name TEXT,
        ip TEXT,
        port INTEGER,
        lastSeen INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        peerId TEXT,
        title TEXT,
        lastMessage TEXT,
        updatedAt INTEGER,
        FOREIGN KEY(peerId) REFERENCES peers(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        convId TEXT,
        peerId TEXT,
        text TEXT,
        direction TEXT,
        status TEXT,
        timestamp INTEGER,
        FOREIGN KEY(convId) REFERENCES conversations(id),
        FOREIGN KEY(peerId) REFERENCES peers(id)
      );
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
