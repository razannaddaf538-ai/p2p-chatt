import 'package:flutter/material.dart';
import 'app_colors.dart';

/// مكون فقاعة الرسالة
/// عرض الرسائل بشكل جميل مع تمييز الرسائل المرسلة والمستقبلة
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  /// تنسيق الوقت
  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          // لون الفقاعة حسب من أرسلها
          color: isMe ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          // ظل ناعم
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // النص الرئيسي
            Text(
              text,
              style: TextStyle(
                color: isMe ? AppColors.white : AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            // الوقت (اختياري)
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    color: isMe
                        ? AppColors.white.withOpacity(0.7)
                        : AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
