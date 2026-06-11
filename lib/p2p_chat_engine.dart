import 'dart:io';
import 'dart:convert';

/// فئة محرك الاتصال P2P
/// تدير العمليات الأساسية للاتصال بين الأجهزة (نقطة لنقطة)
class P2PChatEngine {
  ServerSocket? _server;
  Socket? _clientSocket;
  
  // Callback لاستقبال الرسائل الواردة
  Function(String message)? onMessageReceived;
  
  // Callback لتنبيهات الأخطاء
  Function(String error)? onError;

  /// بدء تشغيل السيرفر لاستقبال الاتصالات الواردة
  /// 
  /// المعاملات:
  ///   - port: رقم المنفذ الذي سيستمع عليه السيرفر (مثال: 4040)
  Future<void> startServer(int port) async {
    try {
      // ربط السيرفر على جميع عناوين IP المتاحة (anyIPv4)
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      print("✅ السيرفر بدأ التشغيل على: ${_server!.address.address}:${_server!.port}");

      // الاستماع للاتصالات القادمة من الأطراف الأخرى
      _server!.listen(
        (Socket client) {
          print("🔗 اتصال جديد من: ${client.remoteAddress.address}:${client.remotePort}");
          _handleIncomingConnection(client);
        },
        onError: (error) {
          _handleError("خطأ في السيرفر: $error");
        },
        cancelOnError: false, // الاستمرار بالاستماع حتى بعد الأخطاء
      );
    } catch (e) {
      _handleError("فشل تشغيل السيرفر: $e");
    }
  }

  /// معالجة الاتصال الواردة من طرف آخر
  /// 
  /// تستقبل البيانات وتفك ترميزها وتنادي callback onMessageReceived
  void _handleIncomingConnection(Socket client) {
    client.listen(
      (List<int> data) {
        try {
          // فك ترميز البيانات من UTF-8 إلى نص عادي
          String message = utf8.decode(data);
          print("📨 رسالة مستلمة: $message");
          
          // استدعاء الدالة المسجلة لمعالجة الرسالة
          if (onMessageReceived != null) {
            onMessageReceived!(message);
          }
        } catch (e) {
          _handleError("خطأ في فك ترميز الرسالة: $e");
        }
      },
      onError: (error) {
        _handleError("خطأ في الاستقبال: $error");
      },
      onDone: () {
        print("🔌 تم قطع الاتصال");
        client.close();
      },
    );
  }

  /// إرسال رسالة إلى جهاز آخر (وضع الكلاينت)
  /// 
  /// المعاملات:
  ///   - targetIp: عنوان IP الجهاز المستقبِل
  ///   - port: رقم المنفذ على الجهاز المستقبِل
  ///   - message: نص الرسالة المراد إرسالها
  /// 
  /// القيمة المرجعة:
  ///   - true إذا تم الإرسال بنجاح
  ///   - false إذا فشل الإرسال
  Future<bool> sendMessage(String targetIp, int port, String message) async {
    try {
      print("📤 محاولة الاتصال بـ $targetIp:$port");
      
      // الاتصال بالجهاز المستهدف
      _clientSocket = await Socket.connect(
        targetIp,
        port,
        timeout: Duration(seconds: 5), // مهلة زمنية لمحاولة الاتصال
      );
      
      print("✅ تم الاتصال بنجاح!");
      
      // ترميز الرسالة إلى UTF-8 وإرسالها
      _clientSocket!.write(message);
      
      // التأكد من إرسال البيانات فوراً (بدون تأخير)
      await _clientSocket!.flush();
      
      print("📨 تم إرسال الرسالة: $message");
      
      // إغلاق الاتصال لتحرير الموارد
      await _clientSocket!.close();
      _clientSocket = null;
      
      return true;
    } catch (e) {
      _handleError("فشل الإرسال إلى $targetIp: $e");
      return false;
    }
  }

  /// معالجة الأخطاء
  void _handleError(String error) {
    print("❌ $error");
    if (onError != null) {
      onError!(error);
    }
  }

  /// إيقاف السيرفر وتنظيف الموارد
  Future<void> stop() async {
    try {
      _clientSocket?.destroy();
      await _server?.close();
      _server = null;
      _clientSocket = null;
      print("🛑 تم إيقاف السيرفر والعميل");
    } catch (e) {
      _handleError("خطأ عند إيقاف السيرفر: $e");
    }
  }

  /// الحصول على حالة السيرفر
  bool get isServerRunning => _server != null;

  /// الحصول على عنوان الجهاز المحلي
  String? get localAddress => _server?.address.address;

  /// الحصول على رقم المنفذ
  int? get port => _server?.port;
}
