import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;
  final bool isRead;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMine,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final timeColor = isMine
        ? const Color(0xFF646464)
        : (isRead ? const Color(0xFF646464) : Colors.black);

    final backgroundColor = isMine
        ? Colors.white
        : (isRead ? Colors.white : const Color(0xFFFFEB9B));

    final textColor = isMine
        ? const Color(0xFF646464)
        : (isRead ? const Color(0xFF646464) : Colors.black);

    final borderSide = BorderSide(width: 2);
    final borderRadius = BorderRadius.circular(16);

    return Container(
      width: 204,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 39,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 14,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                side: borderSide,
                borderRadius: borderRadius,
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0xFF000000),
                  blurRadius: 0,
                  offset: Offset(4, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: SizedBox(
              width: 168,
              child: Text(
                text,
                textAlign: isMine ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
