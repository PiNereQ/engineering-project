import 'package:equatable/equatable.dart';

class Listing extends Equatable {
  final String id; // Listing ID
  final String couponId; // ID of the coupon this listing contains
  final String sellerId; // Who is selling this listing
  final double price; // Price of the listing (what buyer pays)
  final bool isMultipleUse; // Can this listing be bought multiple times?
  final bool isActive; // Is this listing still for sale?
  final bool isDeleted;
  final bool isBlocked;
  final DateTime? blockedAt;
  final DateTime createdAt; // When was this listing created

  const Listing({
    required this.id,
    required this.couponId,
    required this.sellerId,
    required this.price,
    required this.isMultipleUse,
    required this.isActive,
    required this.isDeleted,
    required this.isBlocked,
    this.blockedAt,
    required this.createdAt,
  });

  /// Create Listing from API JSON response
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id']?.toString() ?? '',
      couponId: json['coupon_id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      price: _parseDouble(json['price']),
      isMultipleUse: _parseBool(json['is_multiple_use']),
      isActive: _parseBool(json['is_active']),
      isDeleted: _parseBool(json['is_deleted']),
      isBlocked: _parseBool(json['is_blocked']),
      blockedAt: json['blocked_at'] != null ? DateTime.parse(json['blocked_at']) : null,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
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
    couponId,
    sellerId,
    price,
    isMultipleUse,
    isActive,
    isDeleted,
    isBlocked,
    blockedAt,
    createdAt,
  ];

  Listing copyWith({
    String? id,
    String? couponId,
    String? sellerId,
    double? price,
    bool? isMultipleUse,
    bool? isActive,
    bool? isDeleted,
    bool? isBlocked,
    DateTime? blockedAt,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      couponId: couponId ?? this.couponId,
      sellerId: sellerId ?? this.sellerId,
      price: price ?? this.price,
      isMultipleUse: isMultipleUse ?? this.isMultipleUse,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedAt: blockedAt ?? this.blockedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
