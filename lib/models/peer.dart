/// نموذج العقدة (Peer) والأصدقاء المصحح
/// 
/// يمثل كل عقدة في النظام وتحتفظ بمعلومات الأصدقاء المتصلين

class Peer {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  late DateTime lastSeen;
  late bool isOnline;

  Peer({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    this.isOnline = true,
  }) {
    lastSeen = DateTime.now();
  }

  /// تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  /// إنشاء Peer من JSON
  factory Peer.fromJson(Map<String, dynamic> json) {
    return Peer(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      isOnline: json['isOnline'] as bool? ?? true,
    );
  }

  /// تحديث حالة الاتصال
  void updateLastSeen() {
    lastSeen = DateTime.now();
  }
}
