import 'package:equatable/equatable.dart';

class CouponOffer extends Equatable {
  
  
  final double price;
  final double discount;
  final bool isDiscountPercentage;
  final String code;
  final bool isActive;
  final bool hasLimits;
  final bool worksInStore;
  final bool worksOnline;
  final int shopId;
  final String ownerId;

  final String? expiryDate; // "YYYY-MM-DD"
  final String? description;

  const CouponOffer({
    required this.price,
    required this.isDiscountPercentage,
    required this.discount,
    required this.code,
    required this.hasLimits,
    required this.worksOnline,
    required this.worksInStore,
    required this.isActive,
    required this.ownerId,
    required this.shopId,

    this.expiryDate,  
    this.description,
  });

  // Convert to JSON for API requests
  // Matches the SQL INSERT: description, price, discount, is_discount_percentage, 
  // expiry_date, code, is_active, has_limits, works_in_store, works_online, shop_id, owner_id
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'price': price,
      'discount': discount,
      'is_discount_percentage': isDiscountPercentage,
      'expiry_date': expiryDate,
      'code': code,
      'is_active': isActive,
      'has_limits': hasLimits,
      'works_in_store': worksInStore,
      'works_online': worksOnline,
      'shop_id': shopId,
      'owner_id': ownerId,
    };
  }

  @override
  List<Object?> get props => [
    discount,
    isDiscountPercentage,
    price,
    code,
    shopId,
    ownerId,
    hasLimits,
    worksOnline,
    worksInStore,
    isActive,
    expiryDate,
    description,
  ];
}