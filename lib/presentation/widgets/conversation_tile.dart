import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final String username;
  final String title;
  final String message;
  final bool isRead;

  const ConversationTile({
    super.key,
    required this.username,
    required this.title,
    required this.message,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: isRead ? Colors.white : const Color(0xFFFFEB9B),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2),
              borderRadius: BorderRadius.circular(16),
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
            width: 347,
            height: 115.71,
            child: Stack(
              children: [
                // Avatar
                Positioned(
                  left: 0,
                  top: 22,
                  child: Container(
                    width: 71,
                    height: 71,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 2),
                        borderRadius: BorderRadius.circular(1000),
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
                    child: const Icon(Icons.person, size: 40),
                  ),
                ),

                // Username
                Positioned(
                  left: 94,
                  top: 14,
                  child: SizedBox(
                    width: 186,
                    child: Text(
                      username,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                        height: 0.75,
                      ),
                    ),
                  ),
                ),

                // Title
                Positioned(
                  left: 95,
                  top: 38,
                  child: SizedBox(
                    width: 185,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                // Message content
                Positioned(
                  left: 95,
                  top: 67,
                  child: SizedBox(
                    width: 250,
                    height: 36,
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isRead ? const Color(0xFF646464) : Colors.black,
                        fontSize: 15,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                // Separator (SVG)
                // Positioned(
                //   left: 370, // Adjust position as necessary
                //   top: 0,
                //   child: Container(
                //     width: 5,
                //     height: 112, // Adjust height as necessary
                //     child: SvgPicture.asset(
                //       'icons/Separator.svg',
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),
                // TODO: svg crash fix

                // Message icon (SVG)
                Positioned(
                  left: 400, // Adjust position as necessary
                  top: 42, // Adjust position as necessary
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      children: [
                        // SvgPicture.asset(
                        //   isRead
                        //       ? 'icons/chat-outline-rounded.svg'
                        //       : 'icons/mark-unread-chat-alt-outline-rounded.svg',
                        //   fit: BoxFit.contain,
                        // ),
                        // TODO: svg crash fix
                        Icon(isRead
                              ? Icons.chat_outlined
                              : Icons.mark_chat_unread_outlined),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
