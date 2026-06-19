class PeerModel {
  final String id;
  final String name;
  final String ip;
  final int port;
  final int lastSeen; // unix timestamp

  PeerModel({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    required this.lastSeen,
  });

  factory PeerModel.fromMap(Map<String, dynamic> m) => PeerModel(
        id: m['id'] as String,
        name: m['name'] as String,
        ip: m['ip'] as String,
        port: m['port'] as int,
        lastSeen: m['lastSeen'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ip': ip,
        'port': port,
        'lastSeen': lastSeen,
      };
}
