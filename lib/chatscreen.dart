import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'core/enhanced_p2p_chat_engine.dart';
import 'core/udp_discovery.dart';
import 'chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? initialTargetIp;
  const ChatScreen({super.key, this.initialTargetIp});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final EnhancedP2PEngine _engine;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _msgController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  final int _port = 4040;

  @override
  void initState() {
    super.initState();
    if (widget.initialTargetIp != null) {
      _ipController.text = widget.initialTargetIp!;
    }
    _engine = EnhancedP2PEngine(port: _port);
    _engine.startServer();
    _engine.incoming.listen((msg) {
      setState(() {
        messages.add({'text': msg.payload['text'], 'isMe': false, 'from': msg.from});
      });
    });
    _engine.logs.listen((l) => print('[ENGINE] $l'));
    UDPDiscovery.instance.start(deviceName: 'P2P-App', listenPort: _port);
  }

  Future<void> _sendMessage() async {
    final targetIp = _ipController.text.trim();
    final text = _msgController.text.trim();
    if (targetIp.isEmpty || text.isEmpty) return;

    final ok = await _engine.sendChat(targetIp, text);
    if (ok) {
      setState(() {
        messages.add({'text': text, 'isMe': true, 'from': 'local'});
      });
      _msgController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإرسال إلى $targetIp')));
    }
  }

  @override
  void dispose() {
    _engine.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("P2P Live Chat"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "IP الصديق (مثال: 192.168.1.5)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lan),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  text: messages[index]["text"],
                  isMe: messages[index]["isMe"],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "اكتب رسالة...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Color(0xFFF8A8C8)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
