
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmRepository {
  static const _fcmTokenPrefsKey = 'last_sent_fcm_token';
  final UserRepository userRepository;

  FcmRepository({required this.userRepository});

  Future<void> sendFcmTokenToBackend(String? token) async {
    
    if (token == null) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final lastSentToken = prefs.getString(_fcmTokenPrefsKey);
    if (kDebugMode) print(' Obtained FCM token: $token');
    if (kDebugMode) print('Last sent FCM token: $lastSentToken');
    if (lastSentToken == token) {
      if (kDebugMode) print('FCM token unchanged, not re-registering.');
      return;
    }
    try {
      if (kDebugMode) print('Sending FCM token to backend: $token');
      await userRepository.registerFcmToken(userId: userId, token: token);
      await prefs.setString(_fcmTokenPrefsKey, token);
      if (kDebugMode) print('FCM token registered and saved locally.');
    } catch (e) {
      if (kDebugMode) print('Failed to send FCM token to backend: $e');
    }
  }

  Future<void> initFcmTokenManagement() async {
    final token = await FirebaseMessaging.instance.getToken();
    await sendFcmTokenToBackend(token);
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await sendFcmTokenToBackend(newToken);
    });
  }

  /// Force refresh and get a new FCM token
  Future<String?> getNewFcmToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('New FCM token: $token');
      await sendFcmTokenToBackend(token);
      return token;
    } catch (e) {
      debugPrint('Error getting new FCM token: $e');
      return null;
    }
  }
}
