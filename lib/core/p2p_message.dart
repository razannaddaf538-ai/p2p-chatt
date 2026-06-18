class P2PMessage {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final String from;
  final String? to;
  final DateTime timestamp;

  P2PMessage({
    required this.id,
    required this.type,
    required this.payload,
    required this.from,
    this.to,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'payload': payload,
        'from': from,
        'to': to,
        'timestamp': timestamp.toIso8601String(),
      };

  factory P2PMessage.fromMap(Map<String, dynamic> m) {
    return P2PMessage(
      id: m['id'] as String,
      type: m['type'] as String,
      payload: Map<String, dynamic>.from(m['payload'] as Map),
      from: m['from'] as String,
      to: m['to'] as String?,
      timestamp: DateTime.parse(m['timestamp'] as String),
    );
  }
}
