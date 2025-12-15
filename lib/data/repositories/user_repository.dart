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

      await _api.postJson('/users', body: apiBody);
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
      final response = await _api.getJson('/users');
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
      final data = await _api.getJson('/users/$uid');
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
      await _api.putJson('/users/$uid', body: data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Get current user ID from secure storage
  /// Note: This should use the auth token to determine current user
  Future<String?> getCurrentUserId() async {
    // TODO: Implement token-based authentication
    // For now, this is a placeholder
    if (kDebugMode) debugPrint('getCurrentUserId needs authentication implementation');
    return null;
  }

  /// Ensures the current user exists in the API database
  Future<void> ensureUserExistsInApi(String uid, String email, String username) async {
    try {
      // Try to get user from API
      await _api.getJson('/users/$uid');
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
}
