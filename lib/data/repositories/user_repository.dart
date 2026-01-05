import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/api/api_client.dart';

class UserRepository {
  final ApiClient _api;

  UserRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Create user profile via API (POST /users)
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    final now = DateTime.now().toIso8601String();
    try {
      final apiBody = {
        'id': uid,
        'email': email,
        'username': username,
        'joinDate': now,
        'termsAccepted': 1,
        'termsVersionAccepted': '0',
        'termsAcceptedAt': now,
        'privacyPolicyAccepted': 1,
        'privacyPolicyVersionAccepted': '0',
        'privacyPolicyAcceptedAt': now,
      };

      if (kDebugMode) {
        debugPrint('Creating user with API payload: $apiBody');
      }

      await _api.post('/users', body: apiBody);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user in API: $e');
      }
      rethrow;
    }
  }

  /// Check if username is already in use (GET /users and search)
  Future<bool> isUsernameInUse(String? username) async {
    if (username == null || username.isEmpty) return false;
    
    try {
      final response = await _api.get('/users');
      if (response is List) {
        return response.any((user) => user['username'] == username);
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking username: $e');
      return false;
    }
  }

  /// Get user profile by ID (GET /users/{id})
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final data = await _api.get('/users/$uid', useAuthToken: true);
      return data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile (PUT /users/{id})
  /// Note: This endpoint may need to be implemented on the backend
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _api.put('/users/$uid', body: data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Get current user ID from FirebaseAuth
  Future<String> getCurrentUserId() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('No user is currently signed in.');
    }
    return userId;
  }

  /// Get current user token from FirebaseAuth
  Future<String> getCurrentUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to retrieve user token.');
    }
    return token;
  }

  /// Ensures the current user exists in the API database
  Future<void> ensureUserExistsInApi(String uid, String email, String username) async {
    try {
      // Try to get user from API
      await _api.get('/users/$uid', useAuthToken: true);
      if (kDebugMode) {
        debugPrint('User $uid already exists in API');
      }
    } catch (e) {
      // User doesn't exist in API, create them
      if (kDebugMode) {
        debugPrint('User $uid not found in API, creating...');
      }
      
      await createUserProfile(
        uid: uid,
        email: email,
        username: username,
      );
    }
  }

  /// PATCH /users/:id/add_phone_number?phone_number=...
  Future<void> addPhoneNumberToUser({required String uid, required String phoneNumber}) async {
    try {
      await _api.patch('/users/$uid/add-phone-number', body: {'phone_number': phoneNumber}, useAuthToken: true);
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding phone number: $e');
      rethrow;
    }
  }

  /// GET /users/is_phone_number_used?phone_number=...
  Future<bool> isPhoneNumberUsed(String phoneNumber) async {
    try {
      final resp = await _api.get('/users/is-phone-number-used', queryParameters: {'phone_number': phoneNumber});
      if (resp is Map && resp.containsKey('is_used')) {
        return resp['is_used'] == true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking phone number: $e');
      return false;
    }
  }

  /// Register FCM token for user (PUT /users/register-fcm-token/:user_id)
  Future<void> registerFcmToken({required String userId, required String token}) async {
    try {
      await _api.put('/users/register-fcm-token/$userId', body: {'fcm_token': token}, useAuthToken: true);
      if (kDebugMode) debugPrint('Registered FCM token for user $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('Error registering FCM token: $e');
      rethrow;
    }
  }

  /// PATCH /users/{id}/disable
  Future<void> disableAccount(String userId) async {
    try {
      await _api.patch(
        '/users/$userId/disable',
        body: {},
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error disabling account: $e');
      rethrow;
    }
  }

  /// BLOCKING USERS
  /// PUT /users/:uid/blocks/:blocked_uid
  Future<void> blockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    await _api.put(
      '/users/$userId/blocks/$blockedUserId',
      useAuthToken: true,
    );
  }

  /// DELETE /users/:uid/blocks/:blocked_uid
  Future<void> unblockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    await _api.delete(
      '/users/$userId/blocks/$blockedUserId',
      useAuthToken: true,
    );
  }

  /// GET /users/:uid/blocks
  Future<List<Map<String, dynamic>>> getBlockedUsers(String userId) async {
    final resp = await _api.get(
      '/users/$userId/blocks',
      useAuthToken: true,
    );

    return (resp as List).cast<Map<String, dynamic>>();
  }

  /// GET /users/:uid/blocks/blocking/:blocked_uid
  Future<bool> isBlocking({
    required String userId,
    required String otherUserId,
  }) async {
    final resp = await _api.get(
      '/users/$userId/blocks/blocking/$otherUserId',
      useAuthToken: true,
    );

    return resp is Map && resp['is_blocked'] == true;
  }

  /// GET /users/:uid/blocks/blocked-by/:blocking_uid
  Future<bool> isBlockedBy({
    required String userId,
    required String otherUserId,
  }) async {
    final resp = await _api.get(
      '/users/$userId/blocks/blocked-by/$otherUserId',
      useAuthToken: true,
    );

    return resp is Map && resp['is_blocked'] == true;
  }

  /// GET /users/:uid/sold-coupons-amount
  Future<int> getSoldCouponsAmount(String uid) async {
    try {
      final resp = await _api.get(
        '/users/$uid/sold-coupons-amount',
        useAuthToken: true,
      );

      if (resp is Map && resp['sold_coupons_amount'] != null) {
        return resp['sold_coupons_amount'] as int;
      }

      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching sold coupons amount: $e');
      }
      return 0;
    }
  }

  /// GET /users/:uid/purchased-coupons-amount
  Future<int> getPurchasedCouponsAmount(String uid) async {
    try {
      final resp = await _api.get(
        '/users/$uid/purchased-coupons-amount',
        useAuthToken: true,
      );

      if (resp is Map && resp['purchased_coupons_amount'] != null) {
        return resp['purchased_coupons_amount'] as int;
      }

      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching purchased coupons amount: $e');
      }
      return 0;
    }
  }

  /// PATCH /users/:uid/change-profile-picture
  Future<void> changeProfilePicture({
    required String userId,
    required int profilePictureId,
  }) async {
    try {
      await _api.patch(
        '/users/$userId/change-profile-picture',
        body: {
          'profile_picture_id': profilePictureId,
        },
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error changing profile picture: $e');
      }
      rethrow;
    }
  }

  /// Apply FCM notification preferences (PUT /users/apply-fcm-preferences/{user_id})
  Future<void> applyFcmPreferences(
    String userId, {
    required bool chatNotificationsDisabled,
    required bool couponNotificationsDisabled,
  }) async {
    try {
      await _api.put(
        '/users/apply-fcm-preferences/$userId',
        body: {
          'chat_notifications_disabled': chatNotificationsDisabled,
          'coupon_notifications_disabled': couponNotificationsDisabled,
        },
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error applying FCM preferences: $e');
      }
      rethrow;
    }
  }
}
