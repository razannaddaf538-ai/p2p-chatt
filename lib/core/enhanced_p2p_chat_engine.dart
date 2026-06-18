import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'p2p_message.dart';

class EnhancedP2PEngine {
  final int port;
  ServerSocket? _server;
  final Map<String, _PeerConnection> _connections = {};
  final StreamController<P2PMessage> _incoming = StreamController.broadcast();
  final StreamController<P2PMessage> _outgoing = StreamController.broadcast();
  final StreamController<String> _logs = StreamController.broadcast();
  final Uuid _uuid = const Uuid();

  EnhancedP2PEngine({this.port = 4040});

  Stream<P2PMessage> get incoming => _incoming.stream;
  Stream<P2PMessage> get outgoing => _outgoing.stream;
  Stream<String> get logs => _logs.stream;

  Future<void> startServer() async {
    if (_server != null) return;
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _logs.add('Server listening on port $port');
      _server!.listen(_handleNewSocket, onError: (e) => _logs.add('Server error: $e'));
    } catch (e) {
      _logs.add('Failed to start server: $e');
      rethrow;
    }
  }

  void _handleNewSocket(Socket socket) {
    final ip = socket.remoteAddress.address;
    _logs.add('Incoming connection from $ip:${socket.remotePort}');
    final conn = _connections.putIfAbsent(ip, () => _PeerConnection(ip, port, _logs, _onPeerClosed));
    conn.attachSocket(socket, _onMessageFromPeer);
  }

  Future<void> connectToPeer(String ip, {int? targetPort}) async {
    final portToUse = targetPort ?? port;
    final conn = _connections.putIfAbsent(ip, () => _PeerConnection(ip, portToUse, _logs, _onPeerClosed));
    await conn.ensureConnected(onConnect: (s) {
      conn.attachSocket(s, _onMessageFromPeer);
    });
  }

  Future<bool> sendChat(String targetIp, String text, {int retries = 2, Duration timeout = const Duration(seconds: 4)}) async {
    final msg = P2PMessage(
      id: _uuid.v4(),
      type: 'chat',
      payload: {'text': text},
      from: 'local',
      to: targetIp,
    );

    final conn = _connections.putIfAbsent(targetIp, () => _PeerConnection(targetIp, port, _logs, _onPeerClosed));
    bool ok = false;
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        await conn.ensureConnected();
        final acked = await conn.sendWithAck(msg, timeout: timeout);
        _outgoing.add(msg);
        ok = acked;
        if (acked) break;
      } catch (e) {
        _logs.add('Send attempt $attempt failed to $targetIp: $e');
      }
      await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
    }
    if (!ok) _logs.add('Failed to deliver message ${msg.id} to $targetIp after $retries retries.');
    return ok;
  }

  void _onMessageFromPeer(String peerIp, P2PMessage msg) {
    if (msg.type == 'ack') {
      return;
    }
    _sendAck(peerIp, msg.id);
    _incoming.add(msg);
  }

  Future<void> _sendAck(String toIp, String messageId) async {
    final ack = P2PMessage(
      id: _uuid.v4(),
      type: 'ack',
      payload: {'ack_for': messageId},
      from: 'local',
      to: toIp,
    );
    final conn = _connections.putIfAbsent(toIp, () => _PeerConnection(toIp, port, _logs, _onPeerClosed));
    try {
      await conn.ensureConnected();
      await conn.sendRaw(ack);
      _logs.add('Sent ACK for $messageId to $toIp');
    } catch (e) {
      _logs.add('Failed to send ACK to $toIp: $e');
    }
  }

  Future<void> stop() async {
    _logs.add('Stopping engine...');
    for (final c in _connections.values) {
      await c.dispose();
    }
    _connections.clear();
    await _server?.close();
    _server = null;
    await _incoming.close();
    await _outgoing.close();
    await _logs.close();
  }

  void _onPeerClosed(String ip) {
    _connections.remove(ip);
    _logs.add('Peer $ip removed from connections.');
  }
}

class _PeerConnection {
  final String ip;
  final int port;
  final StreamController<String> _logCtrl;
  final void Function(String) _onClosed;

  Socket? _socket;
  StreamSubscription<Uint8List>? _sub;
  final Map<String, Completer<bool>> _pendingAcks = {};

  _PeerConnection(this.ip, this.port, this._logCtrl, this._onClosed);

  void attachSocket(Socket s, void Function(String, P2PMessage) onMsg) {
    _socket = s;
    _logCtrl.add('Attached socket for $ip');
    final buffer = BytesBuilder();
    _sub = s.listen((data) {
      buffer.add(data);
      final bytes = buffer.toBytes();
      int offset = 0;
      while (offset + 4 <= bytes.length) {
        final len = _readLen(bytes, offset);
        if (offset + 4 + len > bytes.length) break;
        final payload = bytes.sublist(offset + 4, offset + 4 + len);
        offset += 4 + len;
        try {
          final raw = utf8.decode(payload);
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final msg = P2PMessage.fromMap(map);
          if (msg.type == 'ack') {
            final ackFor = msg.payload['ack_for'] as String?;
            if (ackFor != null && _pendingAcks.containsKey(ackFor)) {
              _pendingAcks[ackFor]!.complete(true);
              _pendingAcks.remove(ackFor);
            }
          } else {
            onMsg(ip, msg);
          }
        } catch (e) {
          _logCtrl.add('Decode/frame error from $ip: $e');
        }
      }
      if (offset < bytes.length) {
        final rem = bytes.sublist(offset);
        buffer.clear();
        buffer.add(rem);
      } else {
        buffer.clear();
      }
    }, onDone: () {
      _logCtrl.add('Socket done from $ip');
      _cleanup();
      _onClosed(ip);
    }, onError: (e) {
      _logCtrl.add('Socket error from $ip: $e');
      _cleanup();
      _onClosed(ip);
    }, cancelOnError: true);
  }

  Future<void> ensureConnected({void Function(Socket)? onConnect}) async {
    if (_socket != null) return;
    try {
      final s = await Socket.connect(ip, port).timeout(const Duration(seconds: 4));
      onConnect?.call(s);
      attachSocket(s, (peerIp, msg) {});
    } catch (e) {
      _logCtrl.add('Failed to connect to $ip:$port — $e');
      rethrow;
    }
  }

  Future<void> sendRaw(P2PMessage msg) async {
    if (_socket == null) throw StateError('Socket not connected');
    final bytes = utf8.encode(jsonEncode(msg.toMap()));
    final framed = _frame(bytes);
    _socket!.add(framed);
    await _socket!.flush();
  }

  Future<bool> sendWithAck(P2PMessage msg, {Duration timeout = const Duration(seconds: 4)}) async {
    if (_socket == null) throw StateError('Socket not connected');
    final completer = Completer<bool>();
    _pendingAcks[msg.id] = completer;
    await sendRaw(msg);
    return completer.future.timeout(timeout).catchError((_) {
      _pendingAcks.remove(msg.id);
      return false;
    });
  }

  static List<int> _frame(List<int> payload) {
    final len = payload.length;
    final header = ByteData(4)..setUint32(0, len, Endian.big);
    return [...header.buffer.asUint8List(), ...payload];
  }

  static int _readLen(List<int> bytes, int offset) {
    final b0 = bytes[offset];
    final b1 = bytes[offset + 1];
    final b2 = bytes[offset + 2];
    final b3 = bytes[offset + 3];
    return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    try {
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
  }

  void _cleanup() {
    _sub?.cancel();
    try {
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
    for (final c in _pendingAcks.values) {
      if (!c.isCompleted) c.complete(false);
    }
    _pendingAcks.clear();
  }
}
