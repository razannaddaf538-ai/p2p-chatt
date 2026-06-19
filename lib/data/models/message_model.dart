class MessageModel {
  final String id;
  final String convId;
  final String peerId;
  final String text;
  final String direction; // 'in' or 'out'
  final String status; // pending,sent,delivered,read,failed
  final int timestamp;

  MessageModel({
    required this.id,
    required this.convId,
    required this.peerId,
    required this.text,
    required this.direction,
    required this.status,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> m) => MessageModel(
        id: m['id'] as String,
        convId: m['convId'] as String,
        peerId: m['peerId'] as String,
        text: m['text'] as String,
        direction: m['direction'] as String,
        status: m['status'] as String,
        timestamp: m['timestamp'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'convId': convId,
        'peerId': peerId,
        'text': text,
        'direction': direction,
        'status': status,
        'timestamp': timestamp,
      };
}
