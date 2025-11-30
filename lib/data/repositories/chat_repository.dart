import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/models/message_model.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:collection/collection.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

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
      couponTitle: 'Kupon 20% Empik',
      buyerId: currentUserId,
      sellerId: 'seller-1',
      buyerUsername: 'Ty',
      sellerUsername: 'Sprzedawca1',
      lastMessage: 'Hej, ten kupon jest nadal dostępny?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      isReadByBuyer: true,
      isReadBySeller: true,
    );

    final conv2 = Conversation(
      id: 'conv-2',
      couponId: 'coupon-xyz',
      couponTitle: 'Kupon 5% Zooplus',
      buyerId: 'buyer-22',
      sellerId: currentUserId,
      buyerUsername: 'Kupujacy22',
      sellerUsername: 'Ty',
      lastMessage: 'Masz jeszcze inne kupony?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isReadByBuyer: false,
      isReadBySeller: true,
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
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
    ];
  }

  // Get conversations for the current user
  Future<List<Conversation>> getConversations({required bool asBuyer}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'User not logged in',
      );
    }

    final userId = user.uid;

    final filtered = asBuyer
        ? _mockConversations.where((c) => c.buyerId == userId)
        : _mockConversations.where((c) => c.sellerId == userId);

    // Obliczamy dynamiczne pole isReadByCurrentUser
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
  Future<Conversation> createConversationIfNotExists({
    required String couponId,
    required String buyerId,
    required String sellerId,
  }) async {
    final existing = _mockConversations.firstWhereOrNull(
      (c) => c.couponId == couponId && c.buyerId == buyerId && c.sellerId == sellerId,
    );

    if (existing != null) {
      return existing;
    }

    // Load usernames
    final buyerProfile = await getUserProfile(buyerId);
    final sellerProfile = await getUserProfile(sellerId);

    final buyerUsername = buyerProfile?['username'] ?? 'Konto';
    final sellerUsername = sellerProfile?['username'] ?? 'Użytkownik';

    // Load coupon title
    final couponDoc =
        await FirebaseFirestore.instance.collection('couponOffers').doc(couponId).get();

    final data = couponDoc.data() ?? {};
    final reduction = data['reduction'] as num? ?? 0;
    final reductionIsPercentage = data['reductionIsPercentage'] as bool? ?? true;

    final String reductionText = reductionIsPercentage
        ? reduction.toString().replaceAll('.', ',')
        : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final String couponTitle = reductionIsPercentage
        ? "Kupon -$reductionText%"
        : "Kupon na $reductionText zł";

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
  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockMessages[conversationId] ?? [];
  }

  // Mark conversation as read BY CURRENT USER
  void markConversationAsRead(String conversationId) {
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null) return;

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
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'not-authenticated', message: 'User not logged in');
    }

    final senderId = user.uid;

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
        isReadByBuyer: senderIsBuyer ? true : false,  // buyer sees read if he sent it
        isReadBySeller: senderIsBuyer ? false : true, // seller sees read if he sent it
      );

      _mockConversations[index] = updated;
    }

    await Future.delayed(const Duration(milliseconds: 150));
  }
  
  bool hasUnreadMessages() {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return false;

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