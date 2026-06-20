/// تطبيق P2P Chat الرئيسي
/// 
/// واجهة المستخدم والربط النهائي لجميع المكونات

import 'package:flutter/material.dart';
import 'models/p2p_message.dart';
import 'models/peer.dart';
import 'network/enhanced_p2p_engine.dart';
import 'network/udp_discovery.dart';

void main() {
  runApp(const P2pChatApp());
}

class P2pChatApp extends StatelessWidget {
  const P2pChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P2P Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const P2pChatScreen(),
    );
  }
}

class P2pChatScreen extends StatefulWidget {
  const P2pChatScreen({Key? key}) : super(key: key);

  @override
  State<P2pChatScreen> createState() => _P2pChatScreenState();
}

class _P2pChatScreenState extends State<P2pChatScreen> {
  late EnhancedP2pEngine _p2pEngine;
  late UdpDiscovery _discovery;
  
  final List<Peer> _peers = [];
  final List<P2pMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  
  late String _peerId;
  late String _peerName;
  late int _peerPort;

  @override
  void initState() {
    super.initState();
    _initializeP2p();
  }

  /// تهيئة نظام P2P
  Future<void> _initializeP2p() async {
    _peerId = 'peer_${DateTime.now().millisecondsSinceEpoch}';
    _peerName = 'User_${_peerId.substring(_peerId.length - 4)}';
    _peerPort = 5555;

    // إنشاء محرك TCP
    _p2pEngine = EnhancedP2pEngine(port: _peerPort);
    await _p2pEngine.startServer();
    
    _p2pEngine.addMessageListener((message) {
      _handleIncomingMessage(message);
    });

    // إنشاء نظام اكتشاف UDP
    _discovery = UdpDiscovery();
    await _discovery.startDiscovery();
    
    _discovery.addPeerFoundListener((ip, port, data) {
      _handlePeerDiscovered(ip, port, data);
    });

    // بث وجودنا
    await _discovery.broadcastPresence(_peerId, _peerName);
    
    setState(() {});
  }

  /// معالجة الرسائل الواردة
  void _handleIncomingMessage(String messageData) {
    try {
      // فك تشفير البيانات
      final parts = messageData.split('|');
      if (parts.length >= 4) {
        final message = P2pMessage(
          id: parts[0],
          senderId: parts[1],
          senderName: parts[2],
          content: parts[3],
        );
        
        setState(() {
          _messages.add(message);
        });
      }
    } catch (e) {
      print('❌ Error handling incoming message: $e');
    }
  }

  /// معالجة اكتشاف عقدة جديدة
  void _handlePeerDiscovered(String ip, int port, String data) {
    try {
      final parts = data.split('|');
      if (parts.length >= 3 && parts[0] == 'PEER_DISCOVERY') {
        final peerId = parts[1];
        final peerName = parts[2];
        
        // عدم إضافة أنفسنا
        if (peerId != _peerId) {
          final peer = Peer(
            id: peerId,
            name: peerName,
            ipAddress: ip,
            port: port,
          );
          
          setState(() {
            if (!_peers.any((p) => p.id == peerId)) {
              _peers.add(peer);
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Found peer: $peerName')),
          );
        }
      }
    } catch (e) {
      print('❌ Error handling peer discovery: $e');
    }
  }

  /// إرسال رسالة
  Future<void> _sendMessage(Peer? selectedPeer) async {
    if (_messageController.text.isEmpty || selectedPeer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter a message and select a peer')),
      );
      return;
    }

    final message = P2pMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _peerId,
      senderName: _peerName,
      content: _messageController.text,
    );

    // إرسال الرسالة
    final messageData = '${message.id}|${message.senderId}|${message.senderName}|${message.content}';
    final success = await _p2pEngine.sendMessage(
      selectedPeer.ipAddress,
      selectedPeer.port,
      messageData,
    );

    if (success) {
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Message sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Chat System'),
        subtitle: Text('ID: $_peerName | Port: $_peerPort'),
      ),
      body: Column(
        children: [
          // قائمة الأصدقاء المكتشفين
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Peers (${_peers.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _peers.map((peer) {
                      return Chip(
                        label: Text(peer.name),
                        avatar: const CircleAvatar(child: Icon(Icons.person)),
                        backgroundColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // منطقة الرسائل
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isOwn = msg.senderId == _peerId;
                      return Align(
                        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isOwn ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isOwn ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isOwn ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // حقل الإدخال
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _peers.isNotEmpty
                      ? () => _sendMessage(_peers.first)
                      : null,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _p2pEngine.stopServer();
    _discovery.stopDiscovery();
    super.dispose();
  }
}
