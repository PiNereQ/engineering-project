import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_event.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:proj_inz/data/models/message_model.dart';
import 'package:proj_inz/presentation/screens/report_screen.dart';
import 'package:proj_inz/presentation/widgets/chat_report_popup.dart';
import 'package:proj_inz/presentation/widgets/coupon_preview_popup.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/star_rating.dart';
import 'package:proj_inz/presentation/widgets/reputation_bar.dart';
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
  final bool isCouponDeleted;
  final VoidCallback onBack;
  final VoidCallback onReport;

  const ChatHeader({
    super.key,
    required this.couponTitle,
    required this.username,
    required this.reputation,
    required this.joinDate,
    required this.isCouponDeleted,
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
                    if (isCouponDeleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.alertButton,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Usunięty kupon',
                            style: TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 13,
                              color: AppColors.alertText,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              CustomIconButton(
                icon: const Icon(Icons.more_vert,
                    size: 24, color: AppColors.textPrimary),
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

                  // reputation
                  ReputationBar(
                    value: reputation,
                    maxWidth: 120,
                    height: 8,
                    showValue: true,
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
                ),
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

              // reputation
              SizedBox(
                width: 120,
                child: ReputationBar(
                  value: reputation,
                  maxWidth: 120,
                  height: 8,
                ),
              ),

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
      width: double.infinity,
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
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Determine which fetch method to use based on user role and coupon status
  Future<Coupon?> fetchCoupon() {
    final isBuyer = currentUserId == buyerId;
    final isSeller = currentUserId == sellerId;

    if (isBuyer) {
      // Buyer logic
      if (initialConversation?.isCouponSold == true) {
        // Fetch owned coupon
        return couponRepo.fetchOwnedCouponDetailsById(couponId);
      } else {
        // Fetch available coupon
        return couponRepo.fetchCouponDetailsById(couponId);
      }
    } else if (isSeller) {
      // Seller logic - always fetch listed coupon
      return couponRepo.fetchListedCouponDetailsById(couponId, currentUserId);
    } else {
      // Fallback - fetch available coupon
      return couponRepo.fetchCouponDetailsById(couponId);
    }
  }

  return FutureBuilder<Coupon?>(
    future: fetchCoupon(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final loadedCoupon = snapshot.data;

      return BlocProvider(
        create: (_) => ChatDetailBloc(
          chatRepository: context.read<ChatRepository>(),
        ),
        child: ChatDetailView(
          initialConversation: initialConversation,
          buyerId: buyerId,
          sellerId: sellerId,
          couponId: couponId,
          relatedCoupon: loadedCoupon,
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
  bool get _isCouponDeleted => _coupon == null;

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
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      repo.markConversationAsRead(_conversation!.id, userId);

      context.read<ChatUnreadBloc>().add(CheckUnreadStatus(userId: userId));

      context.read<ChatDetailBloc>().add(
        LoadMessages(_conversation!.id, raterId: widget.buyerId),
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
            preferredSize: Size.fromHeight(_isCouponDeleted ? 200 : 180),
            child: ChatHeader(
              couponTitle: _conversation != null
                  ? formatChatCouponTitle(
                      reduction: _conversation!.couponDiscount,
                      isPercentage: _conversation!.couponDiscountIsPercentage,
                      shopName: _conversation!.couponShopName,
                    )
                  : widget.relatedCoupon != null
                      ? formatChatCouponTitle(
                          reduction: widget.relatedCoupon!.reduction,
                          isPercentage: widget.relatedCoupon!.reductionIsPercentage,
                          shopName: widget.relatedCoupon!.shopName,
                        )
                      : 'Usunięty kupon',

              username: _conversation != null
                  ? _getOtherUsername()
                  : widget.relatedCoupon?.sellerUsername ?? "Sprzedający",

              reputation: _conversation != null
                  ? 50 // TODO backend
                  : widget.relatedCoupon?.sellerReputation ?? 0,

              joinDate: _conversation != null
                  ? "01.06.2025" // TODO backend
                  : buildJoinDate(widget.relatedCoupon),

              isCouponDeleted: _isCouponDeleted,
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

                      if (state is ChatDetailError) {
                        return Center(
                          child: Text(
                            "Błąd ładowania wiadomości: ${state.message}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (state is ChatDetailLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ChatDetailLoaded || state is ChatDetailSubmittingRating) {
                        final messages = (state as dynamic).messages as List<Message>;
                        final ratingExists = (state as dynamic).ratingExists as bool?;

                        if (messages.isEmpty) {
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

                        final conversationId = _conversation!.id;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                            final isMine = msg.senderId == currentUserId;
                            if (msg.type == 'user') {
                              return ChatBubble(
                              text: msg.text,
                              time: _formatTime(msg.timestamp),
                              isMine: isMine,
                              isUnread: !msg.isRead,
                            );
                            }
                            if (msg.type == 'system') {
                              return SystemMessageCard(
                                msg: msg, 
                                ratingExists: ratingExists,
                                conversationId: conversationId,
                                buyerId: widget.buyerId,
                                sellerId: widget.sellerId,
                                currentUserId: currentUserId,
                              );
                            }
                            return const SizedBox();
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
              color: Colors.black.withValues(alpha: 0.25),
              child: ChatReportPopup(
              onShowCoupon: () {
                setState(() => _showPopup = false);

                if (_coupon == null) {
                  showDialog(
                    context: context,
                    builder: (_) => const _DeletedCouponDialog(),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => CouponPreviewPopup(
                    coupon: _coupon!,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                );
              },           
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (_conversation == null) {
      final conv = await repo.createConversationIfNotExists(
        couponId: widget.couponId,
        buyerId: widget.buyerId,
        sellerId: widget.sellerId
      );

      setState(() {
        _conversation = conv;
      });
    }

    final convId = _conversation!.id;

    await repo.sendMessage(
      conversationId: convId,
      text: text,
      senderId: currentUserId,
    );

    context.read<ChatDetailBloc>().add(
      LoadMessages(convId),
    );

    _controller.clear();

    context.read<ChatUnreadBloc>().add(CheckUnreadStatus(userId: currentUserId));
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
    // Use helper to format time in local timezone
    return formatTimeLocal(time);
  }
}

class SystemMessageCard extends StatefulWidget {
  const SystemMessageCard({
    super.key,
    required this.msg,
    this.ratingExists,
    required this.conversationId,
    required this.buyerId,
    required this.sellerId,
    required this.currentUserId,
  });

  final Message msg;
  final bool? ratingExists;
  final String conversationId;
  final String buyerId;
  final String sellerId;
  final String currentUserId;

  @override
  State<SystemMessageCard> createState() => _SystemMessageCardState();
}

class _SystemMessageCardState extends State<SystemMessageCard> {
  int _ratingStars = 0;
  String? _ratingComment;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    Widget? contents;
    if (widget.msg.text == 'rating_request_for_buyer') {
      if (widget.ratingExists == true) {
        contents = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Dziękujemy za użycie kuponu!",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Już oceniłeś sprzedającego. Dziękujemy za pomoc innym użytkownikom!",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            Text(
              "To jest wiadomość systemowa.\nNie odpowiadaj na nią.",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
          ]
        );
      } else {
        contents = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Dziękujemy za użycie kuponu!",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Nie zapomnij ocenić sprzedającego, aby pomóc innym użytkownikom.",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            StarRating(
              startRating: 0,
              onRatingChanged: (rating) {
                setState(() {
                  _ratingStars = rating;
                });
              },
            ),
            if (_errorText != null) ...[
              SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 14,
                  color: AppColors.alertText,
                ),
              ),
            ],
            SizedBox(height: 8),
            CustomTextButton(
              label: "Oceń", 
              onTap: () {
                setState(() {
                  _errorText = null;
                });
                if (_ratingStars > 0) {
                  final ratedUserId = widget.sellerId;
                  final ratingUserId = widget.currentUserId;
                  final ratedUserIsSeller = true;
                  final ratingValue = _calculateRatingValue(_ratingStars);
                  context.read<ChatDetailBloc>().add(SubmitRating(
                    conversationId: widget.conversationId,
                    ratedUserId: ratedUserId,
                    ratingUserId: ratingUserId,
                    ratedUserIsSeller: ratedUserIsSeller,
                    ratingStars: _ratingStars,
                    ratingValue: ratingValue,
                    ratingComment: _ratingComment,
                  ));
                } else {
                  setState(() {
                    _errorText = "Wybierz od 1 do 5 gwiazdek.";
                  });
                }
              },
            ),
            SizedBox(height: 12),
            Text(
              "To jest wiadomość systemowa.\nNie odpowiadaj na nią.",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
          ]
        );
      }
    } else if (widget.msg.text == 'rating_request_for_seller') {
      if (widget.ratingExists == true) {
        contents = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Kupujący skorzystał z Twojego kuponu!",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Już oceniłeś kupującego. Dziękujemy za pomoc innym użytkownikom!",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            Text(
              "To jest wiadomość systemowa.\nNie odpowiadaj na nią.",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
          ]
        );
      } else {
        contents = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Kupujący skorzystał z Twojego kuponu!",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Nie zapomnij ocenić kupującego, aby pomóc innym użytkownikom.",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            StarRating(
              startRating: 0,
              onRatingChanged: (rating) {
                setState(() {
                  _ratingStars = rating;
                });
              },
            ),
            if (_errorText != null) ...[
              SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 14,
                  color: AppColors.alertText,
                ),
              ),
            ],
            SizedBox(height: 8),
            CustomTextButton(
              label: "Oceń", 
              onTap: () {
                setState(() {
                  _errorText = null;
                });
                if (_ratingStars > 0) {
                  final ratedUserId = widget.buyerId;
                  final ratingUserId = widget.currentUserId;
                  final ratedUserIsSeller = false;
                  final ratingValue = _calculateRatingValue(_ratingStars);
                  context.read<ChatDetailBloc>().add(SubmitRating(
                    conversationId: widget.conversationId,
                    ratedUserId: ratedUserId,
                    ratingUserId: ratingUserId,
                    ratedUserIsSeller: ratedUserIsSeller,
                    ratingStars: _ratingStars,
                    ratingValue: ratingValue,
                    ratingComment: _ratingComment,
                  ));
                } else {
                  setState(() {
                    _errorText = "Wybierz od 1 do 5 gwiazdek.";
                  });
                }
              },
            ),
            SizedBox(height: 12),
            Text(
              "To jest wiadomość systemowa.\nNie odpowiadaj na nią.",
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
          ]
        );
      }
    } else {
      return SizedBox.shrink();
    }
    

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.textPrimary, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: contents
      ),
    );
  }
}

_calculateRatingValue(int stars) {
  // Convert stars (1-5) to rating value (0-100)
  // Leaving this as a switch in case of future changes
  switch (stars) {
    case 1:
      return 0;
    case 2:
      return 25;
    case 3:
      return 50;
    case 4:
      return 75;
    case 5:
      return 100;
    default:
      return 0;
  }
}

class _DeletedCouponDialog extends StatelessWidget {
  const _DeletedCouponDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(width: 2, color: AppColors.textPrimary),
      ),
      title: const Text(
        'Kupon niedostępny',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 22,
          color: AppColors.textPrimary,
        ),
      ),
      content: const Text(
        'Ten kupon został usunięty i nie jest już dostępny.',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        CustomTextButton.primarySmall(
          label: 'OK',
          width: 100,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
