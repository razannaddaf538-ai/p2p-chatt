/// نموذج الرسائل المصحح
/// 
/// يمثل رسالة واحدة في نظام الـ P2P مع جميع المعلومات المطلوبة

class P2pMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  late DateTime timestamp;
  late bool isRead;
  final String? attachmentPath;

  P2pMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.isRead = false,
    this.attachmentPath,
  }) {
    timestamp = DateTime.now();
  }

  /// تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentPath': attachmentPath,
    };
  }

  /// إنشاء رسالة من JSON
  factory P2pMessage.fromJson(Map<String, dynamic> json) {
    return P2pMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool? ?? false,
      attachmentPath: json['attachmentPath'] as String?,
    );
  }

  /// تحديث حالة القراءة
  void markAsRead() {
    isRead = true;
  }
}
