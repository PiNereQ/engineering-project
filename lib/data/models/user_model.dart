import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String? name;
  final String? surname;
  final DateTime? createdAt;
  final int? reputation;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    this.name,
    this.surname,
    this.createdAt,
    this.reputation,
  });




  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nickname: data['nickname'] ?? 'Unknown',
      name: data['name'] ?? 'Unknown',
      surname: data['surname'] ?? 'Unknown',
      email: data['email'] ?? 'Unknown',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      reputation: data['reputation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      'email': email,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (reputation != null) 'reputation': reputation,
    };
  }
}