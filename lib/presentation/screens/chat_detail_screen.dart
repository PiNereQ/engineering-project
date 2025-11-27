import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/chat_bubble.dart';

import 'package:proj_inz/bloc/chat/detail/chat_detail_bloc.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_event.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_state.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';

class ChatDetailScreen extends StatefulWidget {
  /// If the conversation already exists (e.g., we come from the chat list),
  /// we pass it here.
  final Conversation? initialConversation;

  /// Data needed to create a conversation when it doesn't exist yet.
  final String buyerId;
  final String sellerId;
  final String couponId;

  /// Constructor used when we open a chat from a coupon (conversation doesn't exist yet)
  const ChatDetailScreen({
    super.key,
    this.initialConversation,
    required this.buyerId,
    required this.sellerId,
    required this.couponId,
  });

  /// Helper constructor when we already have a Conversation (e.g., from the chat list)
  factory ChatDetailScreen.fromConversation(Conversation conversation, {Key? key}) {
    return ChatDetailScreen(
      key: key,
      initialConversation: conversation,
      buyerId: conversation.buyerId,
      sellerId: conversation.sellerId,
      couponId: conversation.couponId,
    );
  }

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Conversation? _conversation;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _conversation = widget.initialConversation;
    _controller = TextEditingController();

    // if conversation already exists (e.g., we came from the chat list),
    // mark it as read and load messages.
    if (_conversation != null) {
      final repo = context.read<ChatRepository>();
      repo.markConversationAsRead(_conversation!.id);
      context.read<ChatDetailBloc>().add(LoadMessages(_conversation!.id));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _conversation?.couponTitle ?? 'Zapytaj o kupon';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              _getOtherUsername(),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
              builder: (context, state) {
                if (_conversation == null) {
                  // conversation doesn't exist yet, no messages
                  return const Center(
                    child: Text(
                      'Napisz pierwszą wiadomość, żeby rozpocząć rozmowę.',
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
                      child: Text('Brak wiadomości. Napisz coś jako pierwszy!'),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: state.messages.map((msg) {
                      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                      final isMine = msg.senderId == currentUserId;

                      return Align(
                        alignment:
                            isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: ChatBubble(
                          text: msg.text,
                          time: _formatTime(msg.timestamp),
                          isMine: isMine,
                          isRead: msg.isRead,
                        ),
                      );
                    }).toList(),
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          // input
          _buildMessageInput(),
        ],
      ),
    );
  }

  String _getOtherUsername() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final c = _conversation;

    if (c == null || currentUserId == null) {
      // Conversation doesn't exist yet - show a general label
      return 'Sprzedający';
    }

    // if current user is  a buyer -> show seller
    if (c.buyerId == currentUserId) {
      return c.sellerUsername;
    }

    // if current user is a seller -> show buyer
    return c.buyerUsername;
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Napisz wiadomość...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              final repo = context.read<ChatRepository>();

              // if conversation doesn't exist yet, create it
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

              context.read<ChatDetailBloc>().add(
                    SendMessage(
                      conversationId: convId,
                      text: text,
                    ),
                  );

              _controller.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
