class Peer {
  final String id;
  final String name;
  final String ip;
  final int port;
  DateTime lastSeen;

  Peer({required this.id, required this.name, required this.ip, required this.port, DateTime? lastSeen}) : lastSeen = lastSeen ?? DateTime.now();

  factory Peer.fromMap(Map<String, dynamic> m) {
    return Peer(
      id: m['id'] as String,
      name: m['name'] as String,
      ip: m['ip'] as String,
      port: (m['port'] as num).toInt(),
      lastSeen: DateTime.tryParse(m['timestamp'] as String) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'ip': ip, 'port': port, 'lastSeen': lastSeen.toIso8601String()};
}
