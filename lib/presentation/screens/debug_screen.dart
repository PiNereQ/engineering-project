import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/repositories/fcm_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';


class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
    String? _fcmToken;
    Future<void> _getNewFcmToken() async {
      final repo = FcmRepository(userRepository: context.read<UserRepository>()); // UserRepository not needed for token fetch
      final token = await repo.getNewFcmToken();
      if (mounted) {
        setState(() {
          _fcmToken = token;
        });
      }
      if (token != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New FCM token: $token')),
        );
      }
    }
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

  Future<void> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (mounted) {
        setState(() {
          _authToken = token;
        });
      }
      // Print to console
      print('Auth Token: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'),),
      body: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auth Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _authToken ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _getNewFcmToken,
                    child: const Text('Get New FCM Token'),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _fcmToken != null ? 'FCM Token: $_fcmToken' : 'No FCM token fetched yet.',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            Text(formatReduction(20, true)),
            Text(formatReduction(20.1 , true)),
            Text(formatReduction(20, false)),
            Text(formatReduction(20.1, false)),
          ],
        ),
      )
    );
  }
}
