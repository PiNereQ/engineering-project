import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/message_model.dart';
import 'package:proj_inz/data/models/conversation_model.dart';
import 'package:proj_inz/data/api/api_client.dart';

/// Repository for managing chat conversations and messages.
/// Handles API communication for chat-related features such as fetching conversations,
/// creating new conversations, retrieving messages, sending messages, and marking conversations as read.
class ChatRepository {
  final ApiClient _api;
  ChatRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Fetches all chat conversations for the current user.
  /// (GET /chat/conversations?role={buyer|seller}&user={userId})
  ///
  /// [asBuyer] - If true, fetches conversations where the user is the buyer; otherwise as seller.
  /// [userId] - The ID of the current user.
  ///
  /// Returns a list of [Conversation] objects.
  /// Throws on API/network errors.
  Future<List<Conversation>> getConversations({required bool asBuyer, required String userId}) async {
    try {
      if (kDebugMode) print('Fetching conversations for userId: $userId asBuyer: $asBuyer');
      final response = await _api.get(
        '/chat/conversations',
        queryParameters: {
          'role': asBuyer ? 'buyer' : 'seller',
        },
        useAuthToken: true,
      );
      final List<dynamic> conversationsData = response is List ? response : [];
      final conversations = conversationsData.map((data) {
        Conversation conversation = Conversation.fromJson(
          data as Map<String, dynamic>,
        );
        if (asBuyer) {
          conversation = conversation.copyWith(
            isReadByCurrentUser: conversation.isReadByBuyer,
          );
        } else {
          conversation = conversation.copyWith(
            isReadByCurrentUser: conversation.isReadBySeller,
          );
        }
        return conversation;
      }).toList();

      return conversations;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching coupons from API: $e');
      rethrow;
    }
  }

  /// Checks if a conversation already exists between a buyer and seller for a given coupon.
  /// (GET /chat/conversations/exists)
  ///
  /// [couponId] - The coupon's ID.
  /// [buyerId] - The buyer's user ID.
  /// [sellerId] - The seller's user ID.
  /// [currentUserId] - The ID of the current user.
  ///
  /// Returns the [Conversation] if it exists, or null otherwise.
  /// Throws on API/network errors.
  Future<Conversation?> findExistingConversation({
    required String couponId,
    required String buyerId,
    required String sellerId,
    required String currentUserId,
  }) async {
    try {
      final response = await _api.get(
        '/chat/conversations/exists',
        queryParameters: {
          'coupon_id': couponId,
          'buyer_id': buyerId,
          'seller_id': sellerId,
          'user_id': currentUserId,
        },
        useAuthToken: true,
      );
      if (response == null) {
        return null;
      }
      return Conversation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching conversation from API: $e');
      rethrow;
    }
  }

  /// Creates a new conversation in the API if it does not already exist.
  /// (POST /chat/conversations)
  ///
  /// [couponId] - The coupon's ID.
  /// [buyerId] - The buyer's user ID.
  /// [sellerId] - The seller's user ID.
  ///
  /// Returns the created or existing [Conversation].
  /// Throws on API/network errors.
  Future<Conversation> createConversationIfNotExists({
    required String couponId,
    required String buyerId,
    required String sellerId,
    required String currentUserId,
  }) async {
    final existing = await findExistingConversation(couponId: couponId, buyerId: buyerId, sellerId: sellerId, currentUserId: currentUserId);
    if (existing != null) {
      return existing;
    }

    final newConversation = {
      'coupon_id': couponId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
    };

    try {
      final response = await _api.post(
        '/chat/conversations',
         body: newConversation,
         useAuthToken: true,
         );
      return Conversation.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating conversation via API: $e');
      rethrow;
    }
  }

  /// Fetches all messages for a given conversation from the API.
  /// (GET /chat/conversations/{id}/messages)
  ///
  /// [conversationId] - The ID of the conversation.
  /// [userId]
  ///
  /// Returns a list of [Message] objects.
  /// Throws on API/network errors.
  Future<List<Message>> getMessages(String conversationId, String userId) async {
    try {
    final response = await _api.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: {
        'user_id': userId,
      },
      useAuthToken: true,
    );
      return (response as List).map((data) {
        return Message.fromJson(data as Map<String, dynamic>);
    }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching messages from API: $e');
      }
      rethrow;
    }
  }

  /// Marks a conversation as read for a specific user in the API.
  /// (PATCH /chat/conversations/{id}/read)
  ///
  /// [conversationId] - The ID of the conversation to mark as read.
  /// [userId] - The ID of the user who has read the conversation.
  ///
  /// Throws on API/network errors.
  void markConversationAsRead(String conversationId, String userId) {
    try {
      _api.patch(
        '/chat/conversations/$conversationId/read',
        body: {
          'user_id': userId,
        },
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking conversation as read in API: $e');
      }
      rethrow;
    }
  }

  /// Sends a new message in a conversation to the API.
  /// (POST /chat/conversations/{id}/messages)
  ///
  /// [conversationId] - The ID of the conversation.
  /// [text] - The message content.
  /// [senderId] - The ID of the user sending the message.
  ///
  /// Throws on API/network errors.
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderId,
  }) async {
    final newMessage = {
      "sender_id": senderId,
      "content": text
    };
    try {
      await _api.post('/chat/conversations/$conversationId/messages', body: newMessage, useAuthToken: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending message to API: $e');
      }
      rethrow;
    }
  }
  
  /// Checks if there are any unread messages for the current user.
  /// (GET /chat/unread-summary)
  ///
  /// [currentUserId] - The ID of the current user.
  ///
  /// Returns true if there are unread messages, false otherwise.
  /// Throws on API/network errors.
  Future<bool> hasUnreadMessages(String currentUserId) async {
    try {
      final response = await _api.get('/chat/unread-summary', queryParameters: {"user-id": currentUserId}, useAuthToken: true);
      return (response as Map<String, dynamic>)['has_unread'] == 1 ? true : false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching unread messages summary from API: $e');
      }
      rethrow;
    }
  }

  Future<bool> checkIfRatingByBuyerExists(String raterId, String conversationId) async {
    try {
      final response = await _api.get(
        '/ratings/rating-by-buyer-exists/$raterId/$conversationId',
        useAuthToken: true,
      );
      return (response as Map<String, dynamic>)['exists'];
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking rating existence from API: $e');
      rethrow;
    }
  }

  Future<bool> checkIfRatingBySellerExists(String raterId, String conversationId) async {
    try {
      final response = await _api.get(
        '/ratings/rating-by-seller-exists/$raterId/$conversationId',
        useAuthToken: true,
      );
      return (response as Map<String, dynamic>)['exists'];
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking rating existence from API: $e');
      rethrow;
    }
  }

  Future<void> submitRating({
    required String conversationId,
    required String ratedUserId,
    required String ratingUserId,
    required bool ratedUserIsSeller,
    required int ratingStars,
    required int ratingValue,
    String? ratingComment,
  }) async {
    final ratingData = {
      'conversation_id': int.parse(conversationId),
      'rated_user_id': ratedUserId,
      'rating_user_id': ratingUserId,
      'rated_user_is_seller': ratedUserIsSeller,
      'rating_stars': ratingStars,
      'rating_value': ratingValue,
      'rating_comment': ratingComment,
    };

    try {
      await _api.post(
        '/ratings',
        body: ratingData,
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error submitting rating via API: $e');
      rethrow;
    }
  }
}