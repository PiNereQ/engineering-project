import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_event.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/presentation/screens/report_screen.dart';
import 'package:proj_inz/presentation/widgets/chat_report_popup.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import '../widgets/chat_bubble.dart';

import 'package:proj_inz/bloc/chat/detail/chat_detail_bloc.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_event.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_state.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

class ChatHeader extends StatelessWidget {
  final String couponTitle;
  final String username;
  final int reputation;
  final String joinDate;
  final VoidCallback onBack;
  final VoidCallback onReport;

  const ChatHeader({
    super.key,
    required this.couponTitle,
    required this.username,
    required this.reputation,
    required this.joinDate,
    required this.onBack,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row with back and report button, titles
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomIconButton(
                icon: SvgPicture.asset('assets/icons/back.svg'),
                  onTap: onBack,
                ),
              const SizedBox(width: 16),

              // titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chat dotyczący:",
                      style: TextStyle(
                        fontFamily: 'Itim',
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      couponTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              CustomIconButton(
                icon: const Icon(Icons.report,
                    size: 24, color: AppColors.alertText),
                onTap: onReport,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // user info - avatar, username, reputation, join date
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: ShapeDecoration(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(width: 2, color: AppColors.textPrimary),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: AppColors.textPrimary,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    )
                  ],
                ),
                child: const Icon(Icons.person, size: 30),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey.shade300,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (reputation / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reputation.toString(),
                        style: const TextStyle(
                          fontFamily: 'Itim',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Na Coupidynie od $joinDate",
                    style: const TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ChatUserInfo extends StatelessWidget {
  final String username;
  final int reputation;
  final String joinDate;

  const ChatUserInfo({
    super.key,
    required this.username,
    required this.reputation,
    required this.joinDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // avatar
          Container(
            width: 54,
            height: 54,
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(width: 2, color: AppColors.textPrimary),
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.textPrimary,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                )
              ],
            ),
            child: const Icon(Icons.person, size: 30),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Container(
                    width: 120,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade300,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (reputation / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    reputation.toString(),
                    style: const TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Text(
                "Na Coupidynie od $joinDate",
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessagesContainer extends StatelessWidget {
  final Widget child;

  const ChatMessagesContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(width: 2, color: AppColors.textPrimary),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(width: 2, color: AppColors.textPrimary),
                ),
                shadows: const [
                  BoxShadow(
                    color: AppColors.textPrimary,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'treść wiadomości...',
                  hintStyle: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          CustomIconButton(
            icon: const Icon(Icons.send, color: AppColors.textPrimary),
            onTap: onSend,
          ),
        ],
      ),
    );
  }
}

// main screen
class ChatDetailScreen extends StatelessWidget {
  final Conversation? initialConversation;

  final String buyerId;
  final String sellerId;
  final String couponId;
  final Coupon? relatedCoupon;

  const ChatDetailScreen({
    super.key,
    this.initialConversation,
    required this.buyerId,
    required this.sellerId,
    required this.couponId,
    this.relatedCoupon,
  });

  factory ChatDetailScreen.fromConversation(Conversation conversation, {Key? key}) {
    return ChatDetailScreen(
      key: key,
      initialConversation: conversation,
      buyerId: conversation.buyerId,
      sellerId: conversation.sellerId,
      couponId: conversation.couponId,
      relatedCoupon: null,
    );
  }

@override
Widget build(BuildContext context) {
  final couponRepo = context.read<CouponRepository>();

  return FutureBuilder<Coupon>(
    future: couponRepo.fetchCouponDetailsById(couponId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final loadedCoupon = snapshot.data!;

      return BlocProvider(
        create: (_) => ChatDetailBloc(
          chatRepository: context.read<ChatRepository>(),
        ),
        child: ChatDetailView(
          initialConversation: initialConversation,
          buyerId: buyerId,
          sellerId: sellerId,
          couponId: couponId,
          relatedCoupon: loadedCoupon, // ← GOTOWO PRZEKAZANY KUPON
        ),
      );
    },
  );
}
}



// statefdul view
class ChatDetailView extends StatefulWidget {
  final Conversation? initialConversation;
  final String buyerId;
  final String sellerId;
  final String couponId;
  final Coupon? relatedCoupon;

  const ChatDetailView({
    super.key,
    required this.initialConversation,
    required this.buyerId,
    required this.sellerId,
    required this.couponId,
    this.relatedCoupon,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  Conversation? _conversation;
  Coupon? _coupon;
  late final TextEditingController _controller;
  bool _showPopup = false;

  String buildCouponTitle(Coupon c) {
    final reduction = c.reduction;

    final reductionText = formatNumber(reduction);

    final shopName = c.shopName;

    return c.reductionIsPercentage
        ? "-$reductionText% • $shopName"
        : "-$reductionText zł • $shopName";
  }

  String buildJoinDate(Coupon? c) {
    if (c == null || c.sellerJoinDate == null) return "—";

    final d = c.sellerJoinDate!;
    return "${d.day.toString().padLeft(2,'0')}"
           ".${d.month.toString().padLeft(2,'0')}"
           ".${d.year}";
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _conversation = widget.initialConversation;
    _coupon = widget.relatedCoupon;

    if (_conversation != null) {
      final repo = context.read<ChatRepository>();
      repo.markConversationAsRead(_conversation!.id);

      context.read<ChatUnreadBloc>().add(CheckUnreadStatus());

      context.read<ChatDetailBloc>().add(
        LoadMessages(_conversation!.id),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(180),
            child: ChatHeader(
              couponTitle: _conversation != null
                  ? _conversation!.couponTitle
                  : (widget.relatedCoupon != null
                      ? buildCouponTitle(widget.relatedCoupon!)
                      : "Kupon"),

              username: _conversation != null
                  ? _getOtherUsername()
                  : widget.relatedCoupon?.sellerUsername ?? "Sprzedający",

              reputation: _conversation != null
                  ? 50 // TODO backend
                  : widget.relatedCoupon?.sellerReputation ?? 0,

              joinDate: _conversation != null
                  ? "01.06.2025" // TODO backend
                  : buildJoinDate(widget.relatedCoupon),

              onBack: () => Navigator.pop(context),
              onReport: () => setState(() => _showPopup = true),
            ),
          ),

          body: Column(
            children: [
              // big container
              Expanded(
                child: ChatMessagesContainer(
                  child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
                    builder: (context, state) {
                      if (_conversation == null) {
                        return const Center(
                          child: Text(
                            "Zapytaj o ten kupon, wysyłając pierwszą wiadomość!",
                            style: TextStyle(fontFamily: 'Itim', fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (state is ChatDetailLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ChatDetailLoaded) {
                        if (state.messages.isEmpty) {
                          return const Center(
                            child: Text(
                              "Brak wiadomości. Napisz coś jako pierwszy!",
                              style: TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final msg = state.messages[index];
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                            final isMine = msg.senderId == currentUserId;

                            return ChatBubble(
                              text: msg.text,
                              time: _formatTime(msg.timestamp),
                              isMine: isMine,
                              isUnread: !msg.isRead,
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ),

              ChatInputBar(
                controller: _controller,
                onSend: _handleSendMessage,
              )
            ],
          ),
        ),

        // report popup
        if (_showPopup)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: ChatReportPopup(
                onReport: () {
                  final currentUser = FirebaseAuth.instance.currentUser!.uid;

                  final otherUserId = widget.buyerId == currentUser
                      ? widget.sellerId
                      : widget.buyerId;

                  setState(() => _showPopup = false);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportScreen(
                        reportedUserId: otherUserId,
                        reportedUsername: _conversation != null
                            ? _getOtherUsername()
                            : widget.relatedCoupon?.sellerUsername ?? "Użytkownik",

                        reportedUserReputation: _conversation != null
                            ? 50 // TODO backend
                            : widget.relatedCoupon?.sellerReputation ?? 0,

                        reportedUserJoinDate: _conversation != null
                            ? DateTime(2025, 6, 1) // TODO backend
                            : widget.relatedCoupon?.sellerJoinDate ?? DateTime.now(),
                        reportedCoupon: 
                            _coupon != null && FirebaseAuth.instance.currentUser!.uid != _coupon!.sellerId
                                ? _coupon
                                : null,

                      ),
                    ),
                  );
                },
                onBlock: () {
                  // TODO backend
                  setState(() => _showPopup = false);
                },
                onClose: () {
                  setState(() => _showPopup = false);
                },
              ),
            ),
          ),
      ],
    );
  }


  Future<void> _handleSendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final repo = context.read<ChatRepository>();

    if (_conversation == null) {
      final conv = await repo.createConversationIfNotExists(
        couponId: widget.couponId,
        buyerId: widget.buyerId,
        sellerId: widget.sellerId,
      );

      setState(() {
        _conversation = conv;
      });
    }

    final convId = _conversation!.id;

    await repo.sendMessage(
      conversationId: convId,
      text: text,
    );

    context.read<ChatDetailBloc>().add(
      LoadMessages(convId),
    );

    _controller.clear();

    context.read<ChatUnreadBloc>().add(CheckUnreadStatus());
  }


  String _getOtherUsername() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final c = _conversation;

    if (c == null || currentUserId == null) return "Sprzedający";

    return c.buyerId == currentUserId
        ? c.sellerUsername
        : c.buyerUsername;
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}

String formatNumber(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toString().replaceAll('.', ',');
}