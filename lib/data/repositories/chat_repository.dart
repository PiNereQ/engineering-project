import 'dart:async';
import 'package:proj_inz/data/models/message_model.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:collection/collection.dart';
import 'package:proj_inz/data/api/api_client.dart';

// TODO: Backend API endpoints needed:
// - GET /conversations (list user's conversations)
// - POST /conversations (create new conversation)
// - GET /conversations/{id}/messages (get messages for conversation)
// - POST /conversations/{id}/messages (send message)
// - PATCH /conversations/{id}/read (mark as read)

class ChatRepository {
  final ApiClient _api;

  final List<Conversation> _mockConversations = [];
  final Map<String, List<Message>> _mockMessages = {};

  ChatRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  // Get conversations for the current user
  // TODO: Replace with API call to GET /conversations?asBuyer={true|false}
  Future<List<Conversation>> getConversations({required bool asBuyer, required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filtered = asBuyer
        ? _mockConversations.where((c) => c.buyerId == userId)
        : _mockConversations.where((c) => c.sellerId == userId);

    return filtered
        .map((c) => c.copyWith(
              isReadByCurrentUser: asBuyer ? c.isReadByBuyer : c.isReadBySeller,
            ))
        .toList();
  }

  // check if a conversation already exists
  Conversation? findExistingConversation({
    required String couponId,
    required String buyerId,
    required String sellerId,
  }) {
    return _mockConversations.firstWhereOrNull(
      (c) =>
          c.couponId == couponId &&
          c.buyerId == buyerId &&
          c.sellerId == sellerId,
    );
  }

  // Create a conversation if it does not exist
  // TODO: Replace with API call to POST /conversations
  Future<Conversation> createConversationIfNotExists({
    required String couponId,
    required String buyerId,
    required String sellerId,
    required String buyerUsername,
    required String sellerUsername,
  }) async {
    final existing = _mockConversations.firstWhereOrNull(
      (c) => c.couponId == couponId && c.buyerId == buyerId && c.sellerId == sellerId,
    );

    if (existing != null) {
      return existing;
    }

    // TODO: Get coupon details from API
    final couponTitle = "Coupon";

    final newConv = Conversation(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      couponId: couponId,
      couponTitle: couponTitle,
      buyerId: buyerId,
      sellerId: sellerId,
      buyerUsername: buyerUsername,
      sellerUsername: sellerUsername,
      lastMessage: "",
      lastMessageTime: DateTime.now(),
      isReadByBuyer: true,
      isReadBySeller: true,
    );

    _mockConversations.add(newConv);
    _mockMessages[newConv.id] = [];

    return newConv;
  }

  // Get messages
  // TODO: Replace with API call to GET /conversations/{id}/messages
  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockMessages[conversationId] ?? [];
  }

  // Mark conversation as read
  // TODO: Replace with API call to PATCH /conversations/{id}/read
  void markConversationAsRead(String conversationId, String userId) {
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final c = _mockConversations[index];

    final updated = (userId == c.buyerId)
        ? c.copyWith(isReadByBuyer: true)
        : c.copyWith(isReadBySeller: true);

    _mockConversations[index] = updated;

    final messages = _mockMessages[conversationId];
    if (messages != null && messages.isNotEmpty) {
      final last = messages.last;
      messages[messages.length - 1] = last.copyWith(isRead: true);
    }
  }

  // Send new message
  // TODO: Replace with API call to POST /conversations/{id}/messages
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderId,
  }) async {
    final newMessage = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _mockMessages.putIfAbsent(conversationId, () => []);
    _mockMessages[conversationId]!.add(newMessage);

    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _mockConversations[index];

      final bool senderIsBuyer = conv.buyerId == senderId;

      final updated = conv.copyWith(
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        isReadByBuyer: senderIsBuyer ? true : false,
        isReadBySeller: senderIsBuyer ? false : true,
      );

      _mockConversations[index] = updated;
    }

    await Future.delayed(const Duration(milliseconds: 150));
  }
  
  bool hasUnreadMessages(String currentUserId) {
    for (final c in _mockConversations) {
      if (c.buyerId == currentUserId && c.isReadByBuyer == false) {
        return true;
      }
      if (c.sellerId == currentUserId && c.isReadBySeller == false) {
        return true;
      }
    }
    return false;
  }
}

String formatNumber(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toString().replaceAll('.', ',');
}