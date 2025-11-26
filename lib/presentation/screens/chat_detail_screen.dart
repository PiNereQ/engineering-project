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
  final Conversation conversation;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Mark conversation as read
    context.read<ChatRepository>().markConversationAsRead(widget.conversation.id);

    // Load messages
    context.read<ChatDetailBloc>().add(
          LoadMessages(widget.conversation.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rozmowa: ${widget.conversation.couponId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
              builder: (context, state) {
                if (state is ChatDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatDetailLoaded) {
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

  Widget _buildMessageInput() {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Napisz wiadomość...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<ChatDetailBloc>().add(
                      SendMessage(
                        conversationId: widget.conversation.id,
                        text: text,
                      ),
                    );
                controller.clear();
              }
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