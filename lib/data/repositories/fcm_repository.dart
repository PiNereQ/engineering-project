
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmRepository {
  static const _fcmTokenPrefsKey = 'last_sent_fcm_token';
  final UserRepository userRepository;

  FcmRepository({required this.userRepository});

    /// Register FCM event handlers (foreground, background, cold start)
  void registerHandlers({required BuildContext context}) async {
    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // TODO: Implement behavior for foreground messages, e.g., show a dialog or in-app notification
      final title = message.notification?.title ?? 'Nowa wiadomość';
      final body = message.notification?.body ?? '';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title: $body')),
        );
      }
    });

    // Notification tap handler (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      // TODO: Implement navigation based on payload
      debugPrint('Notification tapped. Data: $data');
    });

    // Cold start (terminated app)
    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        final data = initialMessage.data;
        // TODO: Implement navigation based on payload
        debugPrint('Cold start notification. Data: $data');
      }
    });
  }

  Future<void> sendFcmTokenToBackend(String? token) async {
    if (token == null) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final lastSentToken = prefs.getString(_fcmTokenPrefsKey);
    if (lastSentToken == token) {
      debugPrint('FCM token unchanged, not re-registering.');
      return;
    }
    try {
      await userRepository.registerFcmToken(userId: userId, token: token);
      await prefs.setString(_fcmTokenPrefsKey, token);
      debugPrint('FCM token registered and saved locally.');
    } catch (e) {
      debugPrint('Failed to send FCM token to backend: $e');
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
