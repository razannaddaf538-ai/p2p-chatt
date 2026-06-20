/// محرك الـ TCP المصحح
/// 
/// يدير الاتصالات والاتصالات الثنائية بين العقد باستخدام بروتوكول TCP

import 'dart:io';
import 'dart:async';

class EnhancedP2pEngine {
  late ServerSocket _serverSocket;
  final Map<String, Socket> _connectedPeers = {};
  final List<Function> _messageListeners = [];
  final int port;
  late bool _isRunning = false;

  EnhancedP2pEngine({required this.port});

  /// بدء السيرفر وبدء الاستماع
  Future<bool> startServer() async {
    try {
      _serverSocket = await ServerSocket.bind('0.0.0.0', port);
      _isRunning = true;
      _listenForConnections();
      print('✅ P2P Server started on port: $port');
      return true;
    } catch (e) {
      print('❌ Error starting server: $e');
      return false;
    }
  }

  /// الاستماع للاتصالات الجديدة
  void _listenForConnections() {
    _serverSocket.listen(
      (Socket socket) async {
        final remoteAddress = socket.remoteAddress.address;
        final remotePort = socket.remotePort;
        print('✅ New connection from $remoteAddress:$remotePort');

        socket.listen(
          (List<int> data) {
            final message = String.fromCharCodes(data);
            _notifyListeners(message);
          },
          onError: (error) {
            print('❌ Socket error: $error');
          },
          onDone: () {
            print('❌ Connection closed from $remoteAddress:$remotePort');
          },
        );
      },
    );
  }

  /// إرسال رسالة إلى peer معين
  Future<bool> sendMessage(String peerIp, int peerPort, String message) async {
    try {
      final socket = await Socket.connect(peerIp, peerPort);
      socket.write(message);
      await socket.close();
      print('✅ Message sent to $peerIp:$peerPort');
      return true;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  /// إضافة مستمع للرسائل الجديدة
  void addMessageListener(Function listener) {
    _messageListeners.add(listener);
  }

  /// إخطار جميع المستمعين برسالة جديدة
  void _notifyListeners(String message) {
    for (var listener in _messageListeners) {
      listener(message);
    }
  }

  /// إيقاف السيرفر
  Future<void> stopServer() async {
    try {
      await _serverSocket.close();
      _isRunning = false;
      print('✅ P2P Server stopped');
    } catch (e) {
      print('❌ Error stopping server: $e');
    }
  }

  /// التحقق من حالة السيرفر
  bool get isRunning => _isRunning;
}
