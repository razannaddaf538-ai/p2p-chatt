import 'dart:io';
import 'dart:convert';

// كلاس إدارة الاتصال بين الأجهزة
class P2PEngine {
  void startListening(int port) async {
    var server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print("الجهاز مستعد للاستقبال على المنفذ: $port");
    
    server.listen((client) {
      client.listen((data) {
        print("\nرسالة جديدة من صديقك: ${utf8.decode(data)}");
      });
    });
  }

  void sendMessage(String ip, int port, String msg) async {
    var socket = await Socket.connect(ip, port);
    socket.write(msg);
    await socket.flush();
    socket.destroy();
    print("تم إرسال الرسالة بنجاح!");
  }
}
