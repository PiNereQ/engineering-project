import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/widgets/conversation_tile.dart';

import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isBuying = true;

  final dummyBuyingConversations = [
    {
      'username': 'Sprzedawca1',
      'title': 'Kod do Zalando',
      'message': 'Wysłałem Ci kod, daj znać czy działa.',
      'isRead': false,
    },
    {
      'username': 'Sprzedawca2',
      'title': 'Kod do Empiku',
      'message': 'Dzięki za zakup!',
      'isRead': true,
    },
  ];

  final dummySellingConversations = [
    {
      'username': 'Kupujący1',
      'title': 'Kod do Allegro',
      'message': 'Kiedy otrzymam kod?',
      'isRead': false,
    },
    {
      'username': 'Kupujący2',
      'title': 'Kupon Rossmann',
      'message': 'Super, wszystko działa!',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentConversations = isBuying
        ? dummyBuyingConversations
        : dummySellingConversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiadomości'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('Kupuję', isSelected: isBuying, onTap: () {
                setState(() {
                  isBuying = true;
                });
              }),
              const SizedBox(width: 16),
              _buildTabButton('Sprzedaję', isSelected: !isBuying, onTap: () {
                setState(() {
                  isBuying = false;
                });
              }),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: currentConversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = currentConversations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatDetailScreen(),
                      ),
                    );
                  },
                  child: ConversationTile(
                    username: c['username'] as String,
                    title: c['title'] as String,
                    message: c['message'] as String,
                    isRead: c['isRead'] as bool,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, {required bool isSelected, required VoidCallback onTap}) {
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
                  color: isSelected ? const Color(0xFFB2B2B2) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  shadows: isSelected
                      ? []
                      : [
                          const BoxShadow(
                            color: Color(0xFF000000),
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
                        color: isSelected ? const Color(0xFF646464) : Colors.black,
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
