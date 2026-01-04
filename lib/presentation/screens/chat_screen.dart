import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';

import 'package:proj_inz/core/errors/error_messages.dart';

import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/error_mapper.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:proj_inz/presentation/widgets/conversation_tile.dart';
import 'package:proj_inz/presentation/widgets/error_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isBuying = true;
  int? buyingUnreadCount;
  int? sellingUnreadCount;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ChatListBloc>().add(LoadConversations(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        List<Conversation> currentConversations = [];
        if (state is ChatListLoaded) {
          buyingUnreadCount = state.buyingConversations.where((c) => !c.isReadByCurrentUser).length;
          sellingUnreadCount = state.sellingConversations.where((c) => !c.isReadByCurrentUser).length;
          currentConversations = isBuying ? state.buyingConversations : state.sellingConversations;
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Tabs
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 90,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: isBuying
                              ? CustomTextButton.primary(
                                  label: 'Kupuję',
                                  badgeNumber: (buyingUnreadCount != null && buyingUnreadCount! > 0)
                                      ? buyingUnreadCount
                                      : null,
                                  height: 54,
                                  onTap: () {},
                                )
                              : CustomTextButton(
                                  label: 'Kupuję',
                                  badgeNumber: (buyingUnreadCount != null && buyingUnreadCount! > 0)
                                      ? buyingUnreadCount
                                      : null,
                                  height: 54,
                                  onTap: () {
                                    if (!isBuying) {
                                      setState(() => isBuying = true);
                                    }
                                  },
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: !isBuying
                              ? CustomTextButton.primary(
                                  label: 'Sprzedaję',
                                  badgeNumber: (sellingUnreadCount != null && sellingUnreadCount! > 0)
                                      ? sellingUnreadCount
                                      : null,
                                  height: 54,
                                  onTap: () {},
                                )
                              : CustomTextButton(
                                  label: 'Sprzedaję',
                                  badgeNumber: (sellingUnreadCount != null && sellingUnreadCount! > 0)
                                      ? sellingUnreadCount
                                      : null,
                                  height: 54,
                                  onTap: () {
                                    if (isBuying) {
                                      setState(() => isBuying = false);
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Conversation list based on state
                if (state is ChatListLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is ChatListError) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ErrorCard(
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.textPrimary,
                          ),
                          text: chatErrorMessage(mapErrorToType(state.message)),
                          errorString: state.message,
                        ),
                      ),
                    ),
                  ),
                ]
                else if (state is ChatListLoaded) ...[
                  if (currentConversations.isEmpty) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            isBuying
                                ? "Nie masz jeszcze konwersacji.\n"
                                    "Aby rozpocząć rozmowę, wejdź w szczegóły kuponu "
                                    "i wybierz \"Zapytaj o ten kupon\"."
                                : "Nie masz jeszcze konwersacji.\n"
                                    "Gdy ktoś zapyta o Twój kupon, "
                                    "rozmowa pojawi się tutaj.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SliverMainAxisGroup(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final c = currentConversations[index];

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatDetailScreen.fromConversation(c),
                                      ),
                                    ).then((_) {
                                      final userId =
                                          FirebaseAuth.instance.currentUser?.uid ?? '';
                                      context.read<ChatListBloc>().add(
                                          LoadConversations(userId: userId));
                                    });
                                  },
                                  child: ConversationTile(
                                    username: _getUsername(c),
                                    title: formatChatCouponTitle(
                                      reduction: c.couponDiscount,
                                      isPercentage:
                                          parseBool(c.couponDiscountIsPercentage),
                                      shopName: c.couponShopName,
                                    ),
                                    message: c.lastMessage,
                                    messageType: c.lastMessageType,
                                    isRead: c.isReadByCurrentUser,
                                    isCouponSold: c.isCouponSold,
                                    avatarId: _getAvatarId(c),
                                  ),
                                ),
                              );
                            },
                            childCount: currentConversations.length,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 96),
                        ),
                      ],
                    ),
                  ],
                  // Add the unread check here
                  Builder(
                    builder: (context) {
                      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      context
                          .read<ChatUnreadBloc>()
                          .add(CheckUnreadStatus(userId: userId));
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ]
                else
                  const SliverFillRemaining(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getUsername(Conversation c) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Użytkownik';
    return user.uid == c.buyerId ? c.sellerUsername : c.buyerUsername;
  }

  int? _getAvatarId(Conversation c) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return user.uid == c.buyerId
        ? c.sellerProfilePicture
        : c.buyerProfilePicture;
  }
}