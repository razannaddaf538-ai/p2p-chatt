import 'dart:io';
import 'package:flutter/material.dart';
import 'p2p_chat_engine.dart';

/// نقطة الدخول الرئيسية للتطبيق
void main() {
  runApp(
    const MaterialApp(
      home: P2PChatApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// الحاوية الرئيسية للتطبيق (Stateful Widget)
class P2PChatApp extends StatefulWidget {
  const P2PChatApp({Key? key}) : super(key: key);

  @override
  State<P2PChatApp> createState() => _P2PChatAppState();
}

/// حالة التطبيق - تدير منطق الاتصال والواجهة
class _P2PChatAppState extends State<P2PChatApp> {
  // محرك الاتصال P2P
  late P2PChatEngine _chatEngine;

  // المتحكمات (Controllers) للحقول النصية
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // قائمة الرسائل المرسلة والمستقبلة
  final List<String> _messages = [];

  // رقم المنفذ الثابت
  static const int _port = 4040;

  // عنوان IP الجهاز الحالي
  String _localIp = "جاري التحميل...";

  @override
  void initState() {
    super.initState();
    _initializeChatEngine();
    _getLocalIpAddress();
  }

  /// تهيئة محرك الاتصال P2P
  void _initializeChatEngine() {
    _chatEngine = P2PChatEngine();

    // تعيين الـ Callbacks (الدوال التي سيتم استدعاؤها عند استقبال رسالة أو خطأ)
    _chatEngine.onMessageReceived = (message) {
      setState(() {
        _messages.add("📨 الصديق: $message");
      });
    };

    _chatEngine.onError = (error) {
      _showErrorSnackBar(error);
    };

    // بدء تشغيل السيرفر لاستقبال الرسائل
    _startServer();
  }

  /// بدء تشغيل السيرفر
  Future<void> _startServer() async {
    await _chatEngine.startServer(_port);
    setState(() {});
  }

  /// الحصول على عنوان IP المحلي للجهاز
  Future<void> _getLocalIpAddress() async {
    try {
      // الحصول على عناوين الشبكة المتاحة
      final interfaces = await NetworkInterface.list();
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // البحث عن عنوان IPv4 (وليس IPv6 أو loopback)
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.address.startsWith('127.0')) {
            setState(() {
              _localIp = addr.address;
            });
            return;
          }
        }
      }
    } catch (e) {
      print("خطأ في الحصول على IP: $e");
    }
  }

  /// إرسال الرسالة للطرف الآخر
  Future<void> _sendMessage() async {
    String targetIp = _ipController.text.trim();
    String messageText = _messageController.text.trim();

    // التحقق من عدم ترك الحقول فارغة
    if (targetIp.isEmpty || messageText.isEmpty) {
      _showErrorSnackBar("❌ يجب إدخال IP والرسالة");
      return;
    }

    // محاولة إرسال الرسالة
    bool success = await _chatEngine.sendMessage(targetIp, _port, messageText);

    if (success) {
      setState(() {
        _messages.add("💬 أنا: $messageText");
        _messageController.clear();
      });
      _showSuccessSnackBar("✅ تم إرسال الرسالة بنجاح");
    } else {
      _showErrorSnackBar("❌ فشل الاتصال بـ $targetIp");
    }
  }

  /// عرض رسالة نجاح
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// عرض رسالة خطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// مسح الرسائل
  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  void dispose() {
    // تنظيف الموارد عند إغلاق التطبيق
    _chatEngine.stop();
    _ipController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "P2P Chat (دردشة نقطة لنقطة)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          // زر لمسح الرسائل
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "مسح الرسائل",
            onPressed: _clearMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // عرض معلومات الاتصال
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "🌐 IP الخاص بي: $_localIp",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "🔌 المنفذ: $_port",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // حقل إدخال IP الصديق
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: "IP الصديق (مثال: 192.168.1.5)",
                hintText: "أدخل عنوان IP الجهاز الآخر",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.language),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),

          // عرض الرسائل
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      "📭 لا توجد رسائل بعد",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true, // عرض الرسائل الجديدة في الأسفل
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      String message = _messages[_messages.length - 1 - index];
                      bool isMyMessage = message.startsWith("💬");

                      return Align(
                        alignment: isMyMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMyMessage
                                ? Colors.indigo.shade300
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: isMyMessage ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // حقل إدخال الرسالة وزر الإرسال
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
