import 'dart:convert';

/// أنواع الرسائل المختلفة
enum MessageType {
  text,      // رسالة نصية عادية
  image,     // صورة
  file,      // ملف
  system,    // رسالة نظام
  error,     // رسالة خطأ
}

/// نموذج بيانات الرسالة
class ChatMessage {
  final String id;
  final String senderIp;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderIp,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// تحويل الرسالة إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderIp': senderIp,
      'senderName': senderName,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// إنشاء رسالة من JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderIp: json['senderIp'],
      senderName: json['senderName'],
      content: json['content'],
      type: _parseMessageType(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  /// تحويل String إلى MessageType
  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'MessageType.image':
        return MessageType.image;
      case 'MessageType.file':
        return MessageType.file;
      case 'MessageType.system':
        return MessageType.system;
      case 'MessageType.error':
        return MessageType.error;
      default:
        return MessageType.text;
    }
  }

  @override
  String toString() => 'Message($id - $senderName: $content)';
}

/// معالج الرسائل المتقدم
class MessageHandler {
  // قائمة الرسائل
  final List<ChatMessage> _messages = [];

  // Callbacks للأحداث
  Function(ChatMessage)? onMessageReceived;
  Function(String)? onError;

  /// الحصول على قائمة الرسائل
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// الحصول على عدد الرسائل
  int get messageCount => _messages.length;

  /// الحصول على الرسائل غير المقروءة
  List<ChatMessage> getUnreadMessages() {
    return _messages.where((m) => !m.isRead).toList();
  }

  /// إضافة رسالة جديدة
  void addMessage(ChatMessage message) {
    // التحقق من صحة الرسالة
    if (!_isValidMessage(message)) {
      _handleError("الرسالة غير صالحة: ${message.content}");
      return;
    }

    _messages.add(message);
    
    // ترتيب الرسائل حسب الوقت
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // استدعاء الـ Callback
    if (onMessageReceived != null) {
      onMessageReceived!(message);
    }

    print("✅ تم إضافة رسالة: ${message.id}");
  }

  /// معالجة رسالة نصية واردة
  ChatMessage? processIncomingMessage(
    String rawData,
    String senderIp,
    String senderName,
  ) {
    try {
      // محاولة فك الترميز JSON
      Map<String, dynamic> messageData;
      
      try {
        messageData = jsonDecode(rawData);
      } catch (e) {
        // إذا لم تكن JSON، اعتبرها نص عادي
        messageData = {
          'content': rawData,
          'type': 'MessageType.text',
          'senderName': senderName,
          'senderIp': senderIp,
        };
      }

      // التحقق من وجود المحتوى
      if (!messageData.containsKey('content') || messageData['content'].isEmpty) {
        _handleError("الرسالة لا تحتوي على محتوى");
        return null;
      }

      // إنشاء رسالة جديدة
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderIp: senderIp,
        senderName: senderName,
        content: messageData['content'],
        type: _parseMessageType(messageData['type'] ?? 'MessageType.text'),
      );

      // إضافة الرسالة
      addMessage(message);
      return message;
    } catch (e) {
      _handleError("خطأ في معالجة الرسالة: $e");
      return null;
    }
  }

  /// إنشاء رسالة نصية للإرسال
  String createTextMessage(String content, String senderName) {
    if (content.trim().isEmpty) {
      _handleError("لا يمكن إرسال رسالة فارغة");
      return '';
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderIp: 'local',
      senderName: senderName,
      content: content,
      type: MessageType.text,
    );

    return jsonEncode(message.toJson());
  }

  /// تصفية الرسائل (بحث)
  List<ChatMessage> filterMessages(String query) {
    if (query.isEmpty) {
      return _messages;
    }

    final lowerQuery = query.toLowerCase();
    return _messages.where((msg) {
      return msg.content.toLowerCase().contains(lowerQuery) ||
             msg.senderName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// الحصول على الرسائل من شخص معين
  List<ChatMessage> getMessagesBySender(String senderIp) {
    return _messages.where((msg) => msg.senderIp == senderIp).toList();
  }

  /// الحصول على الرسائل في فترة زمنية معينة
  List<ChatMessage> getMessagesByDateRange(DateTime start, DateTime end) {
    return _messages.where((msg) {
      return msg.timestamp.isAfter(start) && msg.timestamp.isBefore(end);
    }).toList();
  }

  /// تحديد رسالة كمقروءة
  void markMessageAsRead(String messageId) {
    try {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        _messages[index] = ChatMessage(
          id: message.id,
          senderIp: message.senderIp,
          senderName: message.senderName,
          content: message.content,
          type: message.type,
          timestamp: message.timestamp,
          isRead: true,
        );
        print("✅ تم وضع علامة على الرسالة كمقروءة: $messageId");
      }
    } catch (e) {
      _handleError("خطأ في تحديد الرسالة كمقروءة: $e");
    }
  }

  /// حذف رسالة معينة
  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    print("🗑️ تم حذف الرسالة: $messageId");
  }

  /// مسح جميع الرسائل
  void clearAllMessages() {
    _messages.clear();
    print("🧹 تم مسح جميع الرسائل");
  }

  /// مسح الرسائل القديمة (أكثر من X أيام)
  void clearOldMessages(int daysOld) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    _messages.removeWhere((msg) => msg.timestamp.isBefore(cutoffDate));
    print("🧹 تم مسح الرسائل القديمة (أقدم من $daysOld أيام)");
  }

  /// التحقق من صحة الرسالة
  bool _isValidMessage(ChatMessage message) {
    // التحقق من أن المحتوى ليس فارغاً
    if (message.content.trim().isEmpty) {
      return false;
    }

    // التحقق من أن ID موجود
    if (message.id.isEmpty) {
      return false;
    }

    // التحقق من أن sender name موجود
    if (message.senderName.trim().isEmpty) {
      return false;
    }

    return true;
  }

  /// معالجة الأخطاء
  void _handleError(String error) {
    print("❌ $error");
    if (onError != null) {
      onError!(error);
    }
  }

  /// الحصول على إحصائيات الرسائل
  Map<String, dynamic> getStatistics() {
    return {
      'totalMessages': _messages.length,
      'unreadMessages': getUnreadMessages().length,
      'uniqueSenders': _messages.map((m) => m.senderIp).toSet().length,
      'oldestMessage': _messages.isNotEmpty ? _messages.first.timestamp : null,
      'newestMessage': _messages.isNotEmpty ? _messages.last.timestamp : null,
    };
  }

  /// تصدير الرسائل كـ JSON
  String exportMessagesToJson() {
    final data = _messages.map((m) => m.toJson()).toList();
    return jsonEncode(data);
  }

  /// استيراد الرسائل من JSON
  void importMessagesFromJson(String jsonData) {
    try {
      final data = jsonDecode(jsonData) as List;
      for (var item in data) {
        final message = ChatMessage.fromJson(item);
        _messages.add(message);
      }
      // إعادة ترتيب الرسائل
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      print("✅ تم استيراد ${data.length} رسالة");
    } catch (e) {
      _handleError("خطأ في استيراد الرسائل: $e");
    }
  }
}
