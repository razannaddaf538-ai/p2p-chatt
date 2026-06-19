class ConversationModel {
  final String id;
  final String peerId;
  final String? title;
  final String? lastMessage;
  final int updatedAt;

  ConversationModel({
    required this.id,
    required this.peerId,
    this.title,
    this.lastMessage,
    required this.updatedAt,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> m) => ConversationModel(
        id: m['id'] as String,
        peerId: m['peerId'] as String,
        title: m['title'] as String?,
        lastMessage: m['lastMessage'] as String?,
        updatedAt: m['updatedAt'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'peerId': peerId,
        'title': title,
        'lastMessage': lastMessage,
        'updatedAt': updatedAt,
      };
}
