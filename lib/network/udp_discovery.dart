/// محرك الـ UDP المصحح
/// 
/// يدير اكتشاف العقد الأخرى على الشبكة باستخدام بروتوكول UDP

import 'dart:io';
import 'dart:async';

class UdpDiscovery {
  late RawDatagramSocket _discoverySocket;
  final int discoveryPort;
  final int broadcastPort;
  final List<Function> _peerFoundListeners = [];
  late bool _isRunning = false;

  UdpDiscovery({
    this.discoveryPort = 5000,
    this.broadcastPort = 5001,
  });

  /// بدء اكتشاف العقد
  Future<bool> startDiscovery() async {
    try {
      _discoverySocket = await RawDatagramSocket.bind('0.0.0.0', discoveryPort);
      _isRunning = true;
      _listenForBroadcast();
      print('✅ UDP Discovery started on port: $discoveryPort');
      return true;
    } catch (e) {
      print('❌ Error starting discovery: $e');
      return false;
    }
  }

  /// الاستماع للرسائل البث
  void _listenForBroadcast() {
    _discoverySocket.listen(
      (RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _discoverySocket.receive();
          if (datagram != null) {
            final message = String.fromCharCodes(datagram.data);
            final senderIp = datagram.address.address;
            final senderPort = datagram.port;
            print('📡 Discovery message from $senderIp:$senderPort');
            _notifyPeerFound(senderIp, senderPort, message);
          }
        }
      },
    );
  }

  /// إرسال رسالة اكتشاف بث
  Future<bool> broadcastPresence(String peerId, String peerName) async {
    try {
      final message = 'PEER_DISCOVERY|$peerId|$peerName';
      _discoverySocket.send(
        message.codeUnits,
        InternetAddress('255.255.255.255'),
        broadcastPort,
      );
      print('📢 Broadcast presence: $message');
      return true;
    } catch (e) {
      print('❌ Error broadcasting presence: $e');
      return false;
    }
  }

  /// إضافة مستمع لاكتشاف عقد جديدة
  void addPeerFoundListener(Function listener) {
    _peerFoundListeners.add(listener);
  }

  /// إخطار المستمعين باكتشاف عقدة جديدة
  void _notifyPeerFound(String ip, int port, String data) {
    for (var listener in _peerFoundListeners) {
      listener(ip, port, data);
    }
  }

  /// إيقاف الاكتشاف
  Future<void> stopDiscovery() async {
    try {
      _discoverySocket.close();
      _isRunning = false;
      print('✅ UDP Discovery stopped');
    } catch (e) {
      print('❌ Error stopping discovery: $e');
    }
  }

  /// التحقق من حالة الاكتشاف
  bool get isRunning => _isRunning;
}
