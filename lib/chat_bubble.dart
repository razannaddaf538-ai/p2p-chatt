import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {

  final String text;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {

    return Align(

      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(

        margin: EdgeInsets.symmetric(
          vertical: 5,
        ),

        padding: EdgeInsets.all(12),

        decoration: BoxDecoration(

          color: isMe
              ? Color(0xFFF8A8C8)
              : Color(0xFFFFE6F0),

          borderRadius: BorderRadius.circular(15),
        ),

        child: Text(text),
      ),
    );
  }
}
