import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/api/api_client.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserRepository {
  final ApiClient _api;

  UserRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

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

      await _api.postJson('/users', apiBody);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user in API: $e');
      }
      rethrow;
    }
  }

  Future<bool> isUsernameInUse(String? username) async {
    try {
      final query = await _firestore
          .collection('userProfileData')
          .where('username', isEqualTo: username)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('userProfileData').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('userProfileData').doc(uid).update(data);
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// Ensures the current user exists in the API database
  /// Useful for users created before API integration
  Future<void> ensureUserExistsInApi() async {
    final user = await getCurrentUser();
    if (user == null) return;

    try {
      // Try to get user from API
      await _api.getJsonById('/users', user.uid);
      if (kDebugMode) {
        debugPrint('User ${user.uid} already exists in API');
      }
    } catch (e) {
      // User doesn't exist in API, create them
      if (kDebugMode) {
        debugPrint('User ${user.uid} not found in API, creating...');
      }
      
      // Get username from Firestore
      final profile = await getUserProfile(user.uid);
      final username = profile?['username'] ?? 'User';
      
      await createUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        username: username,
      );
    }
  }
}
