import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';


class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'),),
      body: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            CustomTextButton(
              label: '_checkUser',
              onTap: _checkUser
            ),
          ],
        ),
      )
    );
    
  }
}

void _checkUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    debugPrint('Logged in user ID: ${user.uid}');
  } else {
    debugPrint('No user is currently logged in.');
  }
}