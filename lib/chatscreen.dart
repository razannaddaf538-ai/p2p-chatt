import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ServerSocket? _server;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _msgController = TextEditingController();
  List<Map<String, dynamic>> messages = []; 
  final int _port = 4040; 

  @override
  void initState() {
    super.initState();
    _startServer(); 
  }

  Future<void> _startServer() async {
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, _port);
      _server!.listen((client) {
        client.listen((data) {
          setState(() {
            messages.add({
              "text": utf8.decode(data),
              "isMe": false,
            });
          });
        });
      });
    } catch (e) {
      print("خطأ في تشغيل السيرفر: $e");
    }
  }

  Future<void> _sendMessage() async {
    String targetIp = _ipController.text.trim();
    String text = _msgController.text.trim();

    if (targetIp.isEmpty || text.isEmpty) return;

    try {
      Socket socket = await Socket.connect(targetIp, _port);
      socket.write(text);
      await socket.flush();
      socket.destroy();

      setState(() {
        messages.add({
          "text": text,
          "isMe": true,
        });
        _msgController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تعذر الاتصال بالآي بي: $targetIp")),
      );
    }
  }

  @override
  void dispose() {
    _server?.close(); 
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
                labelText: " (الفعلي للصديق (مثال: 192.168.1.5 IP",
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

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFF8A8C8) : const Color(0xFFFFE6F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(text),
      ),
    );
  }
}
