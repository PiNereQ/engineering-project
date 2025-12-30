import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String couponId;
  final double couponDiscount;
  final bool couponDiscountIsPercentage;
  final String couponShopName;
  final bool isCouponSold;
  final String buyerId;
  final String sellerId;
  final String buyerUsername;
  final String sellerUsername;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isReadByBuyer;
  final bool isReadBySeller;

  // this field should not be saved to backend
  final bool isReadByCurrentUser;

  const Conversation( {
    required this.id,
    required this.couponId,
    required this.couponDiscount,
    required this.couponDiscountIsPercentage,
    required this.couponShopName,
    required this.isCouponSold,
    required this.buyerId,
    required this.sellerId,
    required this.buyerUsername,
    required this.sellerUsername,
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
        lastMessage,
        lastMessageTime,
        isReadByBuyer,
        isReadBySeller,
        isReadByCurrentUser,
      ];

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      couponId: json['coupon_id'].toString(),
      couponDiscount: double.parse(json['coupon_discount']),
      couponDiscountIsPercentage: json['coupon_discount_is_percentage'] == 1 ? true : false,
      couponShopName: json['coupon_shop_name'] as String,
      isCouponSold: json['coupon_is_sold'] == 1 ? true : false,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      buyerUsername: json['buyer_username'] as String,
      sellerUsername: json['seller_username'] as String,
      lastMessage: (json['latest_message'] ?? '') as String,
      lastMessageTime: (json['latest_message_timestamp'] != null && (json['latest_message_timestamp'] as String).isNotEmpty)
        ? DateTime.parse(json['latest_message_timestamp'] as String)
        : DateTime.fromMillisecondsSinceEpoch(0),
      isReadByBuyer: json['is_read_by_buyer'] == 1 ? true : false,
      isReadBySeller: json['is_read_by_seller'] == 1 ? true : false,

      // is calculated in repository
      isReadByCurrentUser: true, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupon_id': couponId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'buyer_username': buyerUsername,
      'seller_username': sellerUsername,
      'latest_message': lastMessage,
      'latest_message_time': lastMessageTime.toIso8601String(),

      'is_read_by_buyer': isReadByBuyer,
      'is_read_by_seller': isReadBySeller,

      // dont save isReadByCurrentUser because it's view-only
    };
  }

  Conversation copyWith({
    String? id,
    String? couponId,
    double? couponDiscount,
    bool? couponDiscountIsPercentage,
    String? couponShopName,
    bool? isCouponSold,
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
      couponDiscount: couponDiscount ?? this.couponDiscount,
      couponDiscountIsPercentage: couponDiscountIsPercentage ?? this.couponDiscountIsPercentage,
      couponShopName: couponShopName ?? this.couponShopName,
      isCouponSold: isCouponSold ?? this.isCouponSold,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerUsername: buyerUsername ?? this.buyerUsername,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,

      isReadByBuyer: isReadByBuyer ?? this.isReadByBuyer,
      isReadBySeller: isReadBySeller ?? this.isReadBySeller,

      isReadByCurrentUser:
          isReadByCurrentUser ?? this.isReadByCurrentUser, 
    );
  }
}