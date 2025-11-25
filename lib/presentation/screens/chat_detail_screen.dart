import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_bloc.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_event.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_state.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:proj_inz/presentation/widgets/chat_bubble.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    context
        .read<ChatDetailBloc>()
        .add(LoadMessages(widget.conversation.id));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Rozmowa: ${widget.conversation.couponId}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
              builder: (context, state) {
                if (state is ChatDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatDetailError) {
                  return Center(child: Text("Błąd: ${state.message}"));
                }

                if (state is ChatDetailLoaded ||
                    state is ChatDetailSending) {
                  final messages = state is ChatDetailLoaded
                      ? state.messages
                      : (state as ChatDetailSending).messages;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMine = msg.senderId == currentUser;

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatBubble(
                          text: msg.text,
                          time:
                              "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                          isMine: isMine,
                          isRead: msg.isRead,
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          // input bar
          _buildMessageInput(),
        ],
      ),
    );
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
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              context.read<ChatDetailBloc>().add(
                    SendMessage(
                      conversationId: widget.conversation.id,
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
}