import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserRepository {


  Future<void> createUserProfile({
    required String uid,
    required String email,
  }) async {
    await _firestore.collection('userProfileData').doc(uid).set({
      'username': 'sample_username',
      'reputation': 40, 
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('privateUserInfo').doc(uid).set({
      'email': email,
    });
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
