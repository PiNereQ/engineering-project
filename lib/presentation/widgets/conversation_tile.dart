import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/avatar_view.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';

class ConversationTile extends StatelessWidget {
  final String username;
  final String title;
  final String message;
  final String messageType;
  final bool isRead;
  final bool? isCouponSold;
  final int? avatarId;

  const ConversationTile({
    super.key,
    required this.username,
    required this.title,
    required this.message,
    required this.messageType,
    required this.isRead,
    this.isCouponSold,
    required this.avatarId,
  });

  @override
  Widget build(BuildContext context) {
    String messageText = "";
    if (messageType == "system") {
      if (message == "rating_request_for_buyer") {
        messageText = "Coupidyn: Oceń sprzedającego!";
      } else if (message == "rating_request_for_seller") {
        messageText = "Coupidyn: Oceń kupującego!";
      } else {
        messageText = "Coupidyn: $message";
      }
    } else {
      messageText = message;
    }
    return Container(
      decoration: ShapeDecoration(
      color: isRead
          ? AppColors.surface
          : Color.alphaBlend(
              AppColors.background.withOpacity(0.7),
              AppColors.surface,
            ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  AvatarView(
                    avatarId: avatarId,
                    size: 64,
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Details
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Username
                      Text(
                        username,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontFamily: 'Itim',
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                          height: 0.75,
                        ),
                      ),
                      SizedBox(height: 2),
                      // Title
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontFamily: 'Itim',
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                        ),
                      ),
                     SizedBox(height: 4),
                      // Message content
                      Text(
                        messageText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
                          fontSize: 15,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          height: 0.9
                        ),
                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          // Separator
          DashedSeparator.vertical(length: 115),
      
          // Message icon
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: Center(
              child: Icon(
                size: 32,
                isRead
                    ? Icons.chat_outlined
                    : Icons.mark_unread_chat_alt_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
