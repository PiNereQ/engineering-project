import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import '../widgets/chat_bubble.dart';

import 'package:proj_inz/bloc/chat/detail/chat_detail_bloc.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_event.dart';
import 'package:proj_inz/bloc/chat/detail/chat_detail_state.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';

class ChatHeader extends StatelessWidget {
  final String couponTitle;
  final VoidCallback onBack;
  final VoidCallback onReport;

  const ChatHeader({
    super.key,
    required this.couponTitle,
    required this.onBack,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BACK BUTTON
          CustomIconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 24,
              color: AppColors.textPrimary,
            ),
            onTap: onBack,
          ),

          const SizedBox(width: 16),

          // TEXTS
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

          // ALERT BUTTON
          CustomIconButton(
            icon: const Icon(
              Icons.error_outline,
              size: 24,
              color: AppColors.alertText,
            ),
            onTap: onReport,
          ),
        ],
      ),
    );
  }
}


class ChatUserCard extends StatelessWidget {
  final String username;
  final int reputation;
  final String joinDate;

  const ChatUserCard({
    super.key,
    required this.username,
    required this.reputation,
    required this.joinDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 2, color: AppColors.textPrimary),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AVATAR
          Container(
            width: 60,
            height: 60,
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1000),
                side: const BorderSide(width: 2, color: AppColors.textPrimary),
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.textPrimary,
                  blurRadius: 0,
                  offset: Offset(4, 4),
                )
              ],
            ),
            child: const Icon(Icons.person, size: 32),
          ),

          const SizedBox(width: 16),

          // TEXTY I PASEK
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // USERNAME
                Text(
                  username,
                  style: const TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                // PASEK REPUTACJI (kolor zielony)
                SizedBox(
                  height: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (reputation / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // DATA DOŁĄCZENIA
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
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(12),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: TextField(controller: controller),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
          )
        ],
      ),
    );
  }
}

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
  return Scaffold(
    backgroundColor: AppColors.background,

    // CUSTOM HEADER – zrobimy go w kolejnym kroku
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: ChatHeader(
        couponTitle: _conversation?.couponTitle ?? "Kupon",
        onBack: () => Navigator.pop(context),
        onReport: () {
          // TODO: przejście do zgłoszenia
        },
      ),
    ),

    body: Column(
      children: [
        // USER CARD POD HEADEREM
        ChatUserCard(
          username: _getOtherUsername(),
          reputation: 50,            // tu potem wstawimy prawdziwe dane
          joinDate: "01.06.2025",    // również do podmiany
        ),

        // LISTA WIADOMOŚCI
        Expanded(
          child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
            builder: (context, state) {
              if (_conversation == null) {
                return const Center(
                  child: Text(
                    "Zapytaj o ten kupon, wysyłając pierwszą wiadomość!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 16,
                    ),
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
                      isRead: msg.isRead,
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),

        // DOLNY PASEK WIADOMOŚCI
        ChatInputBar(
          controller: _controller,
          onSend: _handleSendMessage,
        ),
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
Future<void> _handleSendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  final repo = context.read<ChatRepository>();

  // Jeśli rozmowa jeszcze nie istnieje → utwórz ją
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

  // Wyślij wiadomość
  await repo.sendMessage(
    conversationId: convId,
    text: text,
  );

  // Przeładuj wiadomości
  context.read<ChatDetailBloc>().add(
        LoadMessages(convId),
      );

  _controller.clear();
}

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
