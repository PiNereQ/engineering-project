import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/models/message_model.dart';
import 'package:proj_inz/data/models/conversation_model.dart';

// TODO: Replace mock data with real API

class ChatRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  final List<Conversation> _mockConversations = [];

  final Map<String, List<Message>> _mockMessages = {};

  ChatRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final currentUserId = _firebaseAuth.currentUser?.uid ?? 'unknown';

    final conv1 = Conversation(
      id: 'conv-1',
      couponId: 'coupon-abc',
      buyerId: currentUserId,
      sellerId: 'seller-1',
      lastMessage: 'Hej, ten kupon jest nadal dostępny?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      isReadByCurrentUser: true,
    );

    final conv2 = Conversation(
      id: 'conv-2',
      couponId: 'coupon-xyz',
      buyerId: 'buyer-22',
      sellerId: currentUserId,
      lastMessage: 'Masz jeszcze inne kupony?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isReadByCurrentUser: false,
    );

    _mockConversations.addAll([conv1, conv2]);

    _mockMessages['conv-1'] = [
      Message(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: currentUserId,
        text: 'Hej, ten kupon jest nadal dostępny?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
    ];

    _mockMessages['conv-2'] = [
      Message(
        id: 'msg-2',
        conversationId: 'conv-2',
        senderId: 'buyer-22',
        text: 'Masz jeszcze inne kupony?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];
  }

  // Get conversations for the current user
  Future<List<Conversation>> getConversations({required bool asBuyer}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'not-authenticated', message: 'User not logged in');
    }

    final userId = user.uid;

    if (asBuyer) {
      return _mockConversations.where((c) => c.buyerId == userId).toList();
    } else {
      return _mockConversations.where((c) => c.sellerId == userId).toList();
    }
  }

  // Get messages for a given conversation
  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _mockMessages[conversationId] ?? [];
  }

  // Mark conversation as read
  void markConversationAsRead(String conversationId) {
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _mockConversations[index] = _mockConversations[index].copyWith(
        isReadByCurrentUser: true,
      );
    }

    final messages = _mockMessages[conversationId];
    if (messages != null && messages.isNotEmpty) {
      final last = messages.last;
      messages[messages.length - 1] = last.copyWith(isRead: true);
    }
  }

  // Sends a message (locally for now)
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'not-authenticated', message: 'User not logged in');
    }

    final newMessage = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: user.uid,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _mockMessages.putIfAbsent(conversationId, () => []);
    _mockMessages[conversationId]!.add(newMessage);

    // Update last message in conversation
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final updated = _mockConversations[index].copyWith(
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        isReadByCurrentUser: true,
      );
      _mockConversations[index] = updated;
    }

    await Future.delayed(const Duration(milliseconds: 150));
  }
}