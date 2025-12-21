import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/core/utils/utils.dart';

class Coupon extends Equatable {
  // general fields
  final String id;

  final double reduction;
  final bool reductionIsPercentage;
  final int price; // smallest currency unit (e.g., 6800 = 6800 groszy = 68.00 złotych)

  final bool hasLimits;
  final bool worksOnline;
  final bool worksInStore;
  final DateTime? expiryDate; // can be null
  final String description; // empty string if none

  final String shopId;
  final String shopName;
  final Color shopNameColor; 
  final Color shopBgColor;

  final DateTime listingDate;
  final bool isSold;
  
  // specific fields
  //                                 | Available to me | Listed by me | Bought by me |
  final String? sellerId;         // |       YES       |      NO      |     YES      |
  final String? sellerUsername;   // |       YES       |      NO      |     YES      |
  final int? sellerReputation;    // |       YES       |      NO      |     YES      |
  final DateTime? sellerJoinDate; // |       YES       |      NO      |     YES      |
  final bool? isMultipleUse;      // |        NO       |     YES      |      NO      | // Can this coupon be sold multiple times
  final bool? isUsed;             // |        NO       |      NO      |     YES      | // Has this owned coupon been used by me
  final DateTime? purchaseDate;   // |        NO       |      NO      |     YES      | // When I bought this coupon
  final String? transactionId;    // |        NO       |      NO      |     YES      | // ID of the transaction when listing the coupon
  final String? code;             // |        NO       |     YES      |     YES      | // Coupon code


  const Coupon({
    required this.id,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,
    required this.hasLimits,
    required this.worksOnline,
    required this.worksInStore,
    this.expiryDate,
    this.description = '',
    required this.shopId,
    required this.shopName,
    required this.shopNameColor,
    required this.shopBgColor,
    this.sellerId,
    this.sellerUsername,
    this.sellerReputation,
    this.sellerJoinDate,
    required this.isSold,
    required this.listingDate,
    this.isMultipleUse,
    this.isUsed,
    this.purchaseDate,
    this.transactionId,
    this.code,
  }); 

  /// Create Coupon from API JSON response
  factory Coupon.availableToMeFromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      reduction: parseNum(json['discount']),
      reductionIsPercentage: parseBool(json['is_discount_percentage']),
      price: parseInt(json['price']),
      hasLimits: parseBool(json['has_limits']),
      worksOnline: parseBool(json['works_online']),
      worksInStore: parseBool(json['works_in_store']),
      expiryDate: json['expiry_date'] != null 
        ? DateTime.parse(json['expiry_date']) 
        : null,
      description: json['description'] ?? '',
      shopId: json['shop_id']?.toString() ?? '',
      shopName: json['shop_name'] ?? '',
      shopNameColor: parseColor(json['shop_name_color'].toString()),
      shopBgColor: parseColor( json['shop_bg_color'].toString()),
      sellerId: json['seller_id']?.toString() ?? '',
      sellerUsername: json['seller_username'],
      sellerReputation: json['seller_reputation'] == null ? null : parseInt(json['seller_reputation']),
      sellerJoinDate: json['seller_join_date'] != null
        ? DateTime.parse(json['seller_join_date'])
        : null,
      isSold: !parseBool(json['is_active']),
      listingDate: DateTime.parse(json['listing_date']),
    );
  }

  factory Coupon.listedByMeFromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      reduction: parseNum(json['discount']),
      reductionIsPercentage: parseBool(json['is_discount_percentage']),
      price: parseInt(json['price']),
      hasLimits: parseBool(json['has_limits']),
      worksOnline: parseBool(json['works_online']),
      worksInStore: parseBool(json['works_in_store']),
      expiryDate: json['expiry_date'] != null 
        ? DateTime.parse(json['expiry_date']) 
        : null,
      description: json['description'],
      shopId: json['shop_id']?.toString() ?? '',
      shopName: json['shop_name'] ?? 'Shop ${json['shop_id']}',
      shopNameColor: parseColor(json['shop_name_color'].toString()),
      shopBgColor: parseColor(json['shop_bg_color'].toString()),
      isSold: !parseBool(json['is_active']) && json['is_deleted'] != true,
      listingDate: DateTime.parse(json['listing_date']),
      isMultipleUse: parseBool(json['is_multiple_use']),
      code: json['code']?.toString()
    );
  }

  factory Coupon.boughtByMeFromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      reduction: parseNum(json['discount']),
      reductionIsPercentage: parseBool(json['is_discount_percentage']),
      price: parseInt(json['price']),
      hasLimits: parseBool(json['has_limits']),
      worksOnline: parseBool(json['works_online']),
      worksInStore: parseBool(json['works_in_store']),
      expiryDate: json['expiry_date'] != null 
        ? DateTime.parse(json['expiry_date']) 
        : null,
      description: json['description'],
      shopId: json['shop_id']?.toString() ?? '',
      shopName: json['shop_name'] ?? '',
      shopNameColor: parseColor(json['shop_name_color'].toString()),
      shopBgColor: parseColor(json['shop_bg_color'].toString()),
      sellerId: json['seller_id']?.toString() ?? '',
      sellerUsername: json['seller_username'],
      sellerReputation: json['seller_reputation'] == null ? null : parseInt(json['seller_reputation']),
      sellerJoinDate: json['seller_join_date'] != null
        ? DateTime.parse(json['seller_join_date'])
        : null,
      isSold: !parseBool(json['is_active']),
      listingDate: json['listing_date'] != null
        ? DateTime.parse(json['listing_date'])
        : DateTime.now(),
      isUsed: parseBool(json['is_used']),
      purchaseDate: DateTime.parse(json['purchase_date']),
      transactionId: json['transaction_id']?.toString(),
      code: json['code']?.toString()
    );
  }



  @override
  List<Object?> get props => [
    id,
    reduction,
    reductionIsPercentage,
    price,
    hasLimits,
    worksOnline,
    worksInStore,
    expiryDate,
    description,
    shopId,
    shopName,
    shopNameColor,
    shopBgColor,
    listingDate,
    isSold,
    sellerId,
    sellerUsername,
    sellerReputation,
    sellerJoinDate,
    isMultipleUse,
    isUsed,
    purchaseDate,
    code,
  ];

  Coupon copyWith({
    String? id,
    double? reduction,
    bool? reductionIsPercentage,
    int? price,
    bool? hasLimits,
    bool? worksOnline,
    bool? worksInStore,
    DateTime? expiryDate,
    String? description,
    String? shopId,
    String? shopName,
    Color? shopNameColor,
    Color? shopBgColor,
    DateTime? listingDate,
    bool? isSold,
    String? sellerId,
    String? sellerUsername,
    int? sellerReputation,
    DateTime? sellerJoinDate,
    bool? isMultipleUse,
    bool? isUsed,
    DateTime? purchaseDate,
    String? code,
  }) {
    return Coupon(
      id: id ?? this.id,
      reduction: reduction ?? this.reduction,
      reductionIsPercentage: reductionIsPercentage ?? this.reductionIsPercentage,
      price: price ?? this.price,
      hasLimits: hasLimits ?? this.hasLimits,
      worksOnline: worksOnline ?? this.worksOnline,
      worksInStore: worksInStore ?? this.worksInStore,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopNameColor: shopNameColor ?? this.shopNameColor,
      shopBgColor: shopBgColor ?? this.shopBgColor,
      listingDate: listingDate ?? this.listingDate,
      isSold: isSold ?? this.isSold,
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerReputation: sellerReputation ?? this.sellerReputation,
      sellerJoinDate: sellerJoinDate ?? this.sellerJoinDate,
      isMultipleUse: isMultipleUse ?? this.isMultipleUse,
      isUsed: isUsed ?? this.isUsed,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      code: code ?? this.code,
    );
  }
}