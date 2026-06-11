import 'dart:io';
import 'package:flutter/foundation.dart';

/// نموذج بيانات الـ Peer (الجهاز الآخر)
class PeerInfo {
  final String ipAddress;
  final int port;
  final String? deviceName;
  bool isOnline;
  DateTime lastSeen;
  int messageCount;

  PeerInfo({
    required this.ipAddress,
    required this.port,
    this.deviceName,
    this.isOnline = false,
    DateTime? lastSeen,
    this.messageCount = 0,
  }) : lastSeen = lastSeen ?? DateTime.now();

  /// تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'ipAddress': ipAddress,
      'port': port,
      'deviceName': deviceName,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  /// إنشاء كائن من JSON
  factory PeerInfo.fromJson(Map<String, dynamic> json) {
    return PeerInfo(
      ipAddress: json['ipAddress'],
      port: json['port'],
      deviceName: json['deviceName'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      messageCount: json['messageCount'] ?? 0,
    );
  }

  @override
  String toString() => 'Peer($ipAddress:$port - $deviceName)';
}

/// مدير الاتصالات المتعددة
/// يدير عدة اتصالات نشطة مع أجهزة مختلفة في نفس الوقت
class PeerConnectionManager extends ChangeNotifier {
  // قائمة الأصدقاء المتصلين
  final Map<String, PeerInfo> _peers = {};
  
  // الاتصالات النشطة
  final Map<String, Socket> _activeSockets = {};
  
  // Callbacks للأحداث
  Function(PeerInfo)? onPeerConnected;
  Function(PeerInfo)? onPeerDisconnected;
  Function(String error)? onError;

  /// الحصول على قائمة الأصدقاء
  List<PeerInfo> get peers => _peers.values.toList();

  /// الحصول على عدد الأصدقاء المتصلين
  int get connectedPeersCount => _peers.values.where((p) => p.isOnline).length;

  /// إضافة peer جديد
  void addPeer(String ipAddress, int port, {String? deviceName}) {
    final key = '$ipAddress:$port';
    
    if (_peers.containsKey(key)) {
      print("⚠️ هذا الـ Peer موجود بالف��ل: $key");
      return;
    }

    final peer = PeerInfo(
      ipAddress: ipAddress,
      port: port,
      deviceName: deviceName ?? 'جهاز غير معروف',
    );

    _peers[key] = peer;
    notifyListeners(); // تنبيه الـ UI بالتغيير
    print("✅ تم إضافة Peer: $key");
  }

  /// تحديث حالة الـ Peer (متصل أو قاطع)
  void updatePeerStatus(String ipAddress, int port, bool isOnline) {
    final key = '$ipAddress:$port';
    
    if (!_peers.containsKey(key)) {
      print("❌ الـ Peer غير موجود: $key");
      return;
    }

    final peer = _peers[key]!;
    peer.isOnline = isOnline;
    peer.lastSeen = DateTime.now();

    // استدعاء الـ Callback المناسب
    if (isOnline && onPeerConnected != null) {
      onPeerConnected!(peer);
      print("🟢 الـ Peer متصل: $key");
    } else if (!isOnline && onPeerDisconnected != null) {
      onPeerDisconnected!(peer);
      print("🔴 الـ Peer قاطع: $key");
    }

    notifyListeners();
  }

  /// الاتصال بـ Peer معين
  Future<bool> connectToPeer(String ipAddress, int port) async {
    final key = '$ipAddress:$port';

    try {
      print("🔗 محاولة الاتصال بـ $key");
      
      // إذا كان هناك اتصال قديم، أغلقه
      if (_activeSockets.containsKey(key)) {
        _activeSockets[key]?.destroy();
      }

      // محاولة الاتصال
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: Duration(seconds: 5),
      );

      _activeSockets[key] = socket;
      updatePeerStatus(ipAddress, port, true);

      // الاستماع للقطع
      socket.done.then((_) {
        _handlePeerDisconnection(key);
      });

      print("✅ تم الاتصال بـ $key");
      return true;
    } catch (e) {
      _handleError("فشل الاتصال بـ $key: $e");
      updatePeerStatus(ipAddress, port, false);
      return false;
    }
  }

  /// قطع الاتصال مع Peer معين
  Future<void> disconnectFromPeer(String ipAddress, int port) async {
    final key = '$ipAddress:$port';

    if (_activeSockets.containsKey(key)) {
      await _activeSockets[key]?.close();
      _activeSockets.remove(key);
      updatePeerStatus(ipAddress, port, false);
      print("🔌 تم قطع الاتصال مع $key");
    }
  }

  /// إرسال بيانات إلى Peer معين
  Future<bool> sendDataToPeer(
    String ipAddress,
    int port,
    String data,
  ) async {
    final key = '$ipAddress:$port';

    try {
      // التحقق من وجود اتصال نشط
      if (!_activeSockets.containsKey(key)) {
        print("⚠️ لا يوجد اتصال نشط مع $key، محاولة الاتصال...");
        final connected = await connectToPeer(ipAddress, port);
        if (!connected) return false;
      }

      final socket = _activeSockets[key]!;
      socket.write(data);
      await socket.flush();

      // تحديث عدد الرسائل المرسلة
      if (_peers.containsKey(key)) {
        _peers[key]!.messageCount++;
      }

      print("📤 تم إرسال البيانات إلى $key");
      notifyListeners();
      return true;
    } catch (e) {
      _handleError("خطأ في إرسال البيانات إلى $key: $e");
      return false;
    }
  }

  /// معالجة قطع الاتصال مع Peer
  void _handlePeerDisconnection(String key) {
    _activeSockets.remove(key);
    
    final parts = key.split(':');
    if (parts.length == 2) {
      final ip = parts[0];
      final port = int.parse(parts[1]);
      updatePeerStatus(ip, port, false);
    }
  }

  /// معالجة الأخطاء
  void _handleError(String error) {
    print("❌ $error");
    if (onError != null) {
      onError!(error);
    }
  }

  /// الحصول على معلومات Peer معين
  PeerInfo? getPeerInfo(String ipAddress, int port) {
    final key = '$ipAddress:$port';
    return _peers[key];
  }

  /// حذف Peer من القائمة
  Future<void> removePeer(String ipAddress, int port) async {
    final key = '$ipAddress:$port';
    
    // قطع الاتصال أولاً
    await disconnectFromPeer(ipAddress, port);
    
    // حذف من القائمة
    _peers.remove(key);
    notifyListeners();
    print("🗑️ تم حذف Peer: $key");
  }

  /// مسح جميع الاتصالات
  Future<void> clearAllConnections() async {
    for (var socket in _activeSockets.values) {
      await socket.close();
    }
    _activeSockets.clear();
    
    for (var peer in _peers.values) {
      peer.isOnline = false;
    }
    notifyListeners();
    print("🧹 تم مسح جميع الاتصالات");
  }

  /// الحصول على الأصدقاء المتصلين فقط
  List<PeerInfo> getOnlinePeers() {
    return _peers.values.where((p) => p.isOnline).toList();
  }

  /// الحصول على الأصدقاء غير المتصلين
  List<PeerInfo> getOfflinePeers() {
    return _peers.values.where((p) => !p.isOnline).toList();
  }

  /// إعادة محاولة الاتصال مع جميع الأصدقاء غير المتصلين
  Future<void> reconnectOfflinePeers() async {
    print("🔄 محاولة إعادة الاتصال مع الأصدقاء المقطوعين...");
    
    for (var peer in getOfflinePeers()) {
      await Future.delayed(Duration(milliseconds: 500)); // تأخير صغير بين الاتصالات
      await connectToPeer(peer.ipAddress, peer.port);
    }
  }

  /// تنظيف الموارد عند الإيقاف
  @override
  Future<void> dispose() async {
    await clearAllConnections();
    super.dispose();
  }
}
