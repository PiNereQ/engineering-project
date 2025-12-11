import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_event.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_state.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_event.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:proj_inz/presentation/widgets/conversation_tile.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: isBuying
                        ? CustomTextButton.primary(
                            label: 'Kupuję',
                            height: 54,
                            onTap: () {
                              if (!isBuying) {
                                setState(() => isBuying = true);
                                context
                                    .read<ChatListBloc>()
                                    .add(LoadBuyingConversations());
                              }
                            },
                          )
                        : CustomTextButton(
                            label: 'Kupuję',
                            height: 54,
                            onTap: () {
                              if (!isBuying) {
                                setState(() => isBuying = true);
                                context
                                    .read<ChatListBloc>()
                                    .add(LoadBuyingConversations());
                              }
                            },
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: !isBuying
                        ? CustomTextButton.primary(
                            label: 'Sprzedaję',
                            height: 54,
                            onTap: () {
                              if (isBuying) {
                                setState(() => isBuying = false);
                                context
                                    .read<ChatListBloc>()
                                    .add(LoadSellingConversations());
                              }
                            },
                          )
                        : CustomTextButton(
                            label: 'Sprzedaję',
                            height: 54,
                            onTap: () {
                              if (isBuying) {
                                setState(() => isBuying = false);
                                context
                                    .read<ChatListBloc>()
                                    .add(LoadSellingConversations());
                              }
                            },
                          ),
                  ),
                ],
              ),
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
                    context.read<ChatUnreadBloc>().add(CheckUnreadStatus());
                    if (state.conversations.isEmpty) {
                      return const Center(
                        child: Text(
                          'Brak rozmów',
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.conversations.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == state.conversations.length) {
                          return const SizedBox(height: 80); // padding for navbar
                        }

                        final c = state.conversations[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatDetailScreen.fromConversation(c),
                              ),
                            )
                                // reload after returning for updated last message
                                .then((_) {
                              if (isBuying) {
                                context
                                    .read<ChatListBloc>()
                                    .add(LoadBuyingConversations());
                              } else {
                                context
                                    .read<ChatListBloc>()
                                    .add(LoadSellingConversations());
                              }
                            });
                          },
                          child: ConversationTile(
                            username: _getUsername(c),
                            title: c.couponTitle,
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
}
