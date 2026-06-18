import 'dart:convert';
import 'dart:io';
import 'package:p2p_chatt/core/enhanced_p2p_chat_engine.dart';

void main() async {
  final engine = EnhancedP2PEngine(port: 4040);
  engine.logs.listen((l) => print('[LOG] $l'));
  engine.incoming.listen((msg) {
    print('INCOMING: ${msg.from} -> ${msg.payload}');
  });
  await engine.startServer();

  print('Type: send <ip> <message>  OR exit');
  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((line) async {
    if (line.trim() == 'exit') {
      await engine.stop();
      exit(0);
    }
    final parts = line.split(' ');
    if (parts.isNotEmpty && parts[0] == 'send' && parts.length >= 3) {
      final ip = parts[1];
      final message = parts.sublist(2).join(' ');
      final ok = await engine.sendChat(ip, message);
      print(ok ? 'Sent OK' : 'Send failed');
    }
  });
}
