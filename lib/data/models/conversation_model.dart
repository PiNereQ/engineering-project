import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String couponId;
  final String buyerId;
  final String sellerId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isReadByCurrentUser;

  const Conversation({
    required this.id,
    required this.couponId,
    required this.buyerId,
    required this.sellerId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isReadByCurrentUser,
  });

  @override
  List<Object?> get props => [
        id,
        couponId,
        buyerId,
        sellerId,
        lastMessage,
        lastMessageTime,
        isReadByCurrentUser,
      ];

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      couponId: json['couponId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      isReadByCurrentUser: json['isReadByCurrentUser'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couponId': couponId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'isReadByCurrentUser': isReadByCurrentUser,
    };
  }

  Conversation copyWith({
    String? id,
    String? couponId,
    String? buyerId,
    String? sellerId,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isReadByCurrentUser,
  }) {
    return Conversation(
      id: id ?? this.id,
      couponId: couponId ?? this.couponId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isReadByCurrentUser:
          isReadByCurrentUser ?? this.isReadByCurrentUser,
    );
  }
}