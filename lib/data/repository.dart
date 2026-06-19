import 'dart:async';
import 'package:uuid/uuid.dart';
import 'db_provider.dart';
import 'models/peer_model.dart';
import 'models/conversation_model.dart';
import 'models/message_model.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  final DBProvider _dbp = DBProvider();
  final Uuid _uuid = const Uuid();

  // Upsert peer discovered by UDP (or manual)
  Future<void> upsertPeer(PeerModel p) async {
    final db = await _dbp.database;
    await db.insert(
      'peers',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PeerModel>> getPeers() async {
    final db = await _dbp.database;
    final rows = await db.query('peers', orderBy: 'lastSeen DESC');
    return rows.map((r) => PeerModel.fromMap(r)).toList();
  }

  Future<ConversationModel> ensureConversationForPeer(String peerId, {String? title}) async {
    final db = await _dbp.database;
    final rows = await db.query('conversations', where: 'peerId = ?', whereArgs: [peerId], limit: 1);
    if (rows.isNotEmpty) return ConversationModel.fromMap(rows.first);
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final conv = ConversationModel(id: id, peerId: peerId, title: title, lastMessage: null, updatedAt: now);
    await db.insert('conversations', conv.toMap());
    return conv;
  }

  Future<void> saveIncomingMessage(String peerId, String text) async {
    final db = await _dbp.database;
    final conv = await ensureConversationForPeer(peerId);
    final id = _uuid.v4();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final msg = MessageModel(
      id: id,
      convId: conv.id,
      peerId: peerId,
      text: text,
      direction: 'in',
      status: 'delivered',
      timestamp: ts,
    );
    await db.insert('messages', msg.toMap());
    await db.update('conversations', {'lastMessage': text, 'updatedAt': ts}, where: 'id = ?', whereArgs: [conv.id]);
  }

  Future<String> saveOutgoingMessage(String peerId, String text) async {
    final db = await _dbp.database;
    final conv = await ensureConversationForPeer(peerId);
    final id = _uuid.v4();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final msg = MessageModel(
      id: id,
      convId: conv.id,
      peerId: peerId,
      text: text,
      direction: 'out',
      status: 'pending',
      timestamp: ts,
    );
    await db.insert('messages', msg.toMap());
    await db.update('conversations', {'lastMessage': text, 'updatedAt': ts}, where: 'id = ?', whereArgs: [conv.id]);
    return id;
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    final db = await _dbp.database;
    await db.update('messages', {'status': status}, where: 'id = ?', whereArgs: [messageId]);
  }

  Future<List<MessageModel>> getMessagesForPeer(String peerId, {int limit = 100}) async {
    final db = await _dbp.database;
    final convRows = await db.query('conversations', where: 'peerId = ?', whereArgs: [peerId], limit: 1);
    if (convRows.isEmpty) return [];
    final convId = convRows.first['id'] as String;
    final rows = await db.query('messages', where: 'convId = ?', whereArgs: [convId], orderBy: 'timestamp ASC', limit: limit);
    return rows.map((r) => MessageModel.fromMap(r)).toList();
  }

  Future<List<ConversationModel>> getConversations() async {
    final db = await _dbp.database;
    final rows = await db.query('conversations', orderBy: 'updatedAt DESC');
    return rows.map((r) => ConversationModel.fromMap(r)).toList();
  }

  Future<void> deleteConversation(String convId) async {
    final db = await _dbp.database;
    await db.delete('messages', where: 'convId = ?', whereArgs: [convId]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [convId]);
  }

  Future<void> close() async {
    await _dbp.close();
  }
}
