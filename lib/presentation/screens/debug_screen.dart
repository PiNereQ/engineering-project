import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      body: const Column(
        children: [
          CustomTextButton(
            label: '_addMockCoupons',
            onTap: _addMockCoupons
          ),
          CustomTextButton(
            label: '_deleteMockCoupons',
            onTap: _deleteMockCoupons
          ),
          CustomTextButton(
            label: '_checkUser',
            onTap: _checkUser
          ),
        ],
      )
    );
    
  }
}

void _addMockCoupons() async {
  final collection = FirebaseFirestore.instance
        .collection('coupons');
  
  for (var i=0;i<200;i++) {
    await collection.add({
      'code': '000',
      'createdAt': FieldValue.serverTimestamp(),
      'description': 'test',
      'expiryDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'hasLimits': false,
      'isSold': false,
      'pricePLN': i+1,
      'reduction': i+1,
      'reductionIsPercentage': true,
      'sellerId': '0',
      'shopId': '0',
      'worksInStore': true,
      'worksOnline': false
    });
  }
}

void _deleteMockCoupons() {
  final collection = FirebaseFirestore.instance
        .collection('coupons');

  collection.get().then((snapshot) async {
    for (var doc in snapshot.docs) {
      if (doc.id != '0') {
        await doc.reference.delete();
      }
    }
  });
}

void _checkUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    debugPrint('Logged in user ID: ${user.uid}');
  } else {
    debugPrint('No user is currently logged in.');
  }
}