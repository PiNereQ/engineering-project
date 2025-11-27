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

// main wrapper providing the bloc
class ChatDetailScreen extends StatelessWidget {
  // if conversation already exists
  final Conversation? initialConversation;

  final String buyerId;
  final String sellerId;
  final String couponId;

  const ChatDetailScreen({
    super.key,
    this.initialConversation,
    required this.buyerId,
    required this.sellerId,
    required this.couponId,
  });

  // helper when entering from the chat list (conversation already exists)
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatDetailBloc(
        chatRepository: context.read<ChatRepository>(),
      ),
      child: ChatDetailView(
        initialConversation: initialConversation,
        buyerId: buyerId,
        sellerId: sellerId,
        couponId: couponId,
      ),
    );
  }
}
// actual stateful view
class ChatDetailView extends StatefulWidget {
  final Conversation? initialConversation;
  final String buyerId;
  final String sellerId;
  final String couponId;

  const ChatDetailView({
    super.key,
    required this.initialConversation,
    required this.buyerId,
    required this.sellerId,
    required this.couponId,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  Conversation? _conversation;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _conversation = widget.initialConversation;

    // If the conversation already exists -> mark as read and load messages
    if (_conversation != null) {
      final repo = context.read<ChatRepository>();
      repo.markConversationAsRead(_conversation!.id);

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
    final titleText = _conversation?.couponTitle ?? "Zapytaj o kupon";

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
                // Conversation does not exist yet -> prompt to write something
                if (_conversation == null) {
                  return const Center(
                    child: Text(
                      "Zapytaj o ten kupon, wysyłając pierwszą wiadomość!",
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
                      child: Text("Brak wiadomości. Napisz coś jako pierwszy!"),
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
      // conversation not created yet
      return "Sprzedający";
    }

    // if I am the buyer -> show the seller
    if (c.buyerId == currentUserId) {
      return c.sellerUsername;
    }

    // if I am the seller -> show the buyer
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

              // If the conversation does not exist -> create it NOW
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

              // Send the message directly through the repo
              await repo.sendMessage(
                conversationId: convId,
                text: text,
              );

              // Reload messages through bloc
              context.read<ChatDetailBloc>().add(
                    LoadMessages(convId),
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
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
