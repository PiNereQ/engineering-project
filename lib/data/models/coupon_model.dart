import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Coupon extends Equatable {
  final String id;
  final String? listingId; // ID of the listing (if this coupon is listed for sale)
  final double reduction;
  final bool reductionIsPercentage;
  final double price;
  
  final bool hasLimits;
  final bool worksOnline;
  final bool worksInStore;
  final DateTime expiryDate;
  final String? description;

  final String shopId;
  final String shopName;
  final Color shopNameColor; 
  final Color shopBgColor;

  final String sellerId;
  final String? sellerUsername;
  final int sellerReputation;
  final DateTime? sellerJoinDate; 

  final bool isSold;

  const Coupon({
    required this.id,
    this.listingId,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,

    required this.hasLimits,
    required this.worksOnline,
    required this.worksInStore,
    required this.expiryDate,
    this.description,

    required this.shopId,
    required this.shopName,
    required this.shopNameColor,
    required this.shopBgColor,

    required this.sellerId,
    this.sellerUsername,
    required this.sellerReputation,
    this.sellerJoinDate,

    required this.isSold,
  });

  /// Create Coupon from API JSON response
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      reduction: _parseDouble(json['discount']),
      reductionIsPercentage: _parseBool(json['is_discount_percentage']),
      price: _parseDouble(json['price']),
      hasLimits: _parseBool(json['has_limits']),
      worksOnline: _parseBool(json['works_online']),
      worksInStore: _parseBool(json['works_in_store']),
      expiryDate: json['expiry_date'] != null 
        ? DateTime.parse(json['expiry_date']) 
        : DateTime.now(),
      description: json['description'],
      shopId: json['shop_id']?.toString() ?? '',
      shopName: json['shop_name'] ?? 'Shop ${json['shop_id']}', // Fallback if not joined
      shopNameColor: json['shop_name_color'] != null 
        ? Color(int.parse(json['shop_name_color'].toString())) 
        : const Color(0xFF000000),
      shopBgColor: json['shop_bg_color'] != null 
        ? Color(int.parse(json['shop_bg_color'].toString())) 
        : const Color(0xFFFFFFFF),
      sellerId: json['seller_id']?.toString() ?? '',
      sellerUsername: json['seller_username'], // Will be null if not joined
      sellerReputation: _parseInt(json['seller_reputation']),
      sellerJoinDate: json['seller_join_date'] != null
        ? DateTime.parse(json['seller_join_date'])
        : null,
      isSold: !_parseBool(json['is_active']), // is_active:1 means NOT sold
    );
  }

  /// Helper to parse double from various types (String, int, double)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper to parse int from various types (String, int, double)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Helper to parse bool from various types (bool, int, String)
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  List<Object?> get props => [
    id,
    listingId,
    reduction,
    reductionIsPercentage,
    price,
    shopId,
    shopName,
    shopNameColor,
    shopBgColor,
    hasLimits,
    sellerId,
    sellerUsername,
    sellerReputation,
    worksOnline,
    worksInStore,
    expiryDate,
    isSold,
  ];

  Coupon copyWith({
    String? id,
    String? listingId,
    double? reduction,
    bool? reductionIsPercentage,
    double? price,
    bool? hasLimits,
    bool? worksOnline,
    bool? worksInStore,
    DateTime? expiryDate,
    String? description,
    String? shopId,
    String? shopName,
    Color? shopNameColor,
    Color? shopBgColor,
    String? sellerId,
    String? sellerUsername,
    int? sellerReputation,
    DateTime? sellerJoinDate,
    bool? isSold,
  }) {
    return Coupon(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
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
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerReputation: sellerReputation ?? this.sellerReputation,
      sellerJoinDate: sellerJoinDate ?? this.sellerJoinDate,
      isSold: isSold ?? this.isSold,
    );
  }
}