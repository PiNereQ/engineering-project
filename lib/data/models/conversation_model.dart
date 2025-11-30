import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String couponId;
  final String buyerId;
  final String sellerId;
  final String buyerUsername;
  final String sellerUsername;
  final String couponTitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isReadByBuyer;
  final bool isReadBySeller;

  // this field should not be saved to backend
  final bool isReadByCurrentUser;

  const Conversation({
    required this.id,
    required this.couponId,
    required this.buyerId,
    required this.sellerId,
    required this.buyerUsername,
    required this.sellerUsername,
    required this.couponTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isReadByBuyer,
    required this.isReadBySeller,

    // this field should not be saved to backend
    // chatrepository will set it based on current user
    this.isReadByCurrentUser = true,
  });

  @override
  List<Object?> get props => [
        id,
        couponId,
        buyerId,
        sellerId,
        buyerUsername,
        sellerUsername,
        couponTitle,
        lastMessage,
        lastMessageTime,
        isReadByBuyer,
        isReadBySeller,
        isReadByCurrentUser,
      ];

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      couponId: json['couponId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      buyerUsername: json['buyerUsername'] as String,
      sellerUsername: json['sellerUsername'] as String,
      couponTitle: json['couponTitle'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      isReadByBuyer: json['isReadByBuyer'] as bool? ?? true,
      isReadBySeller: json['isReadBySeller'] as bool? ?? true,

      // is calculated in repository
      isReadByCurrentUser: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couponId': couponId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerUsername': buyerUsername,
      'sellerUsername': sellerUsername,
      'couponTitle': couponTitle,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),

      'isReadByBuyer': isReadByBuyer,
      'isReadBySeller': isReadBySeller,

      // dont save isReadByCurrentUser because it's view-only
    };
  }

  Conversation copyWith({
    String? id,
    String? couponId,
    String? buyerId,
    String? sellerId,
    String? buyerUsername,
    String? sellerUsername,
    String? couponTitle,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isReadByBuyer,
    bool? isReadBySeller,
    bool? isReadByCurrentUser,
  }) {
    return Conversation(
      id: id ?? this.id,
      couponId: couponId ?? this.couponId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerUsername: buyerUsername ?? this.buyerUsername,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      couponTitle: couponTitle ?? this.couponTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,

      isReadByBuyer: isReadByBuyer ?? this.isReadByBuyer,
      isReadBySeller: isReadBySeller ?? this.isReadBySeller,

      isReadByCurrentUser:
          isReadByCurrentUser ?? this.isReadByCurrentUser,
    );
  }
}