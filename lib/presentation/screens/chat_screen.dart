import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_event.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_state.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:proj_inz/presentation/widgets/conversation_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isBuying = true;

  @override
  void initState() {
    super.initState();
    // automatically load buying conversations
    context.read<ChatListBloc>().add(LoadBuyingConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Wiadomości'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('Kupuję', isSelected: isBuying, onTap: () {
                setState(() => isBuying = true);
                context.read<ChatListBloc>().add(LoadBuyingConversations());
              }),
              const SizedBox(width: 16),
              _buildTabButton('Sprzedaję', isSelected: !isBuying, onTap: () {
                setState(() => isBuying = false);
                context.read<ChatListBloc>().add(LoadSellingConversations());
              }),
            ],
          ),

          const SizedBox(height: 16),

          // Conversation list
          Expanded(
            child: BlocBuilder<ChatListBloc, ChatListState>(
              builder: (context, state) {
                if (state is ChatListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatListError) {
                  return Center(child: Text('Błąd: ${state.message}'));
                }

                if (state is ChatListLoaded) {
                  if (state.conversations.isEmpty) {
                    return const Center(child: Text('Brak rozmów'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = state.conversations[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(conversation: c),
                            ),
                          )
                          // reload after returning for updated last message
                          .then((_) {
                            if (isBuying) {
                              context.read<ChatListBloc>().add(LoadBuyingConversations());
                            } else {
                              context.read<ChatListBloc>().add(LoadSellingConversations());
                            }
                          });
                        },
                        child: ConversationTile(
                          username: _getUsername(c),
                          title: "${c.couponTitle}",
                          message: c.lastMessage,
                          isRead: c.isReadByCurrentUser,
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getUsername(Conversation c) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Użytkownik';
    }

    // if current user is buyer, show seller username
    return user.uid == c.buyerId ? c.sellerUsername : c.buyerUsername;
  }

  Widget _buildTabButton(String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        padding: isSelected
            ? const EdgeInsets.only(top: 4, left: 4)
            : const EdgeInsets.only(right: 4, bottom: 4),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 132),
              child: Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: isSelected ? AppColors.primaryButtonPressed : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  shadows: isSelected
                      ? []
                      : [
                          const BoxShadow(
                            color: AppColors.textPrimary,
                            blurRadius: 0,
                            offset: Offset(4, 4),
                            spreadRadius: 0,
                          )
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}