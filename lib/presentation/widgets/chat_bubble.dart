import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;
  final bool isUnread;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMine,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine
        ? AppColors.surface
        : (isUnread ? AppColors.background : AppColors.surface);

    final bubbleTextColor = AppColors.textPrimary;

    final alignment =
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMine ? 0 : 8,
              right: isMine ? 8 : 0,
              bottom: 4,
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: bubbleColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 2,
                  color: AppColors.textPrimary,
                ),
                borderRadius: BorderRadius.circular(16), // FULL ROUND
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.textPrimary,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                )
              ],
            ),
            child: Text(
              text,
              textAlign: isMine ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: bubbleTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
