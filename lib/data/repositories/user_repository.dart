import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserRepository {
  Future<void> createUserProfile({
    required String uid,
    required String username,
  }) async {
    await _firestore.collection('userProfileData').doc(uid).set({
      'username': username,
      'reputation': 75, 
      'joinDate': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('privateUserInfo').doc(uid).set({
      // Ustawa o świadczeniu usług drogą elektroniczną (Dz.U.2024.1513 t.j)
      'termsAccepted': true,
      'termsVersionAccepted': '0', // TODO: get current version of Terms & Conditions
      'termsAcceptedAt': FieldValue.serverTimestamp(),
      // Ustawa o ochronie danych osobowych (Dz.U.2019.1781 t.j.)
      'privacyPolicyAccepted': true,
      'privacyPolicyVersionAccepted': '0', // TODO: get current version of Privacy Policy
      'privacyPolicyAcceptedAt': FieldValue.serverTimestamp(),
    });
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

  Future getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }
