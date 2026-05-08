import 'dart:io';
import 'p2p_logic.dart';

void main() async {
  var engine = P2PEngine();

  print("--- مرحباً بك في تطبيق P2P Chat الجامعي ---");
  print("1. ابدأ كـ مستلم (Server Mode)");
  print("2. ابدأ كـ مرسل (Client Mode)");
  stdout.write("اختر وضع التشغيل: ");
  
  var choice = stdin.readLineSync();

  if (choice == '1') {
    // تشغيل السيرفر للاستماع للرسائل القادمة
    engine.startListening(4040);
  } else if (choice == '2') {
    // الاتصال بصديق وإرسال رسالة
    stdout.write("أدخل IP الصديق: ");
    var ip = stdin.readLineSync() ?? "127.0.0.1";
    stdout.write("اكتب رسالتك: ");
    var msg = stdin.readLineSync() ?? "مرحباً!";
    
    engine.sendMessage(ip, 4040, msg);
  }
}
