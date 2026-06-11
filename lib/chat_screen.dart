import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'chat_bubble.dart';
import 'p2p_chat_engine.dart';

/// شاشة الدردشة
/// عرض المحادثة مع peer معين
class ChatScreen extends StatefulWidget {
  final String peerName;
  final String peerIp;
  final P2PChatEngine chatEngine;

  const ChatScreen({
    super.key,
    required this.peerName,
    required this.peerIp,
    required this.chatEngine,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // إعداد الـ callback لاستقبال الرسائل
    widget.chatEngine.onMessageReceived = (message) {
      _addMessage(message, isMe: false);
    };
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// إضافة رسالة للقائمة
  void _addMessage(String message, {required bool isMe}) {
    setState(() {
      _messages.add({
        'text': message,
        'isMe': isMe,
        'timestamp': DateTime.now(),
      });
    });
    
    // التمرير للأسفل تلقائياً
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// إرسال الرسالة
  void _sendMessage() async {
    final message = _messageController.text.trim();
    
    if (message.isEmpty) return;

    // إضافة الرسالة المرسلة للشاشة
    _addMessage(message, isMe: true);
    _messageController.clear();

    // إرسال الرسالة عبر P2P
    try {
      await widget.chatEngine.sendMessage(widget.peerIp, 4040, message);
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإرسال: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.peerName),
            Text(
              widget.peerIp,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
      ),

      /// Body - الرسائل
      body: Column(
        children: [
          /// قائمة الرسائل
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد رسائل بعد',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ابدأ المحادثة الآن!',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ChatBubble(
                        text: msg['text'],
                        isMe: msg['isMe'],
                        timestamp: msg['timestamp'],
                      );
                    },
                  ),
          ),

          /// فاصل
          Divider(
            height: 1,
            color: AppColors.secondary,
          ),

          /// حقل الإدخال والإرسال
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                /// حقل النص
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.secondary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                /// زر الإرسال
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
