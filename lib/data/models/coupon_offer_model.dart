import 'package:equatable/equatable.dart';

class CouponOffer extends Equatable {
  final int price;
  final double discount;
  final bool isDiscountPercentage;
  final String code;
  final bool isActive;
  final bool hasLimits;
  final bool worksInStore;
  final bool worksOnline;
  final int shopId;
  final String ownerId;
  final bool isMultipleUse;

  final String? expiryDate; // "YYYY-MM-DD"
  final String description;

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
    required this.isMultipleUse,
    this.expiryDate,
    required this.description,
  });

  // Convert to JSON for API requests
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
      'seller_id': ownerId,
      'is_multiple_use': isMultipleUse,
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
        isMultipleUse,
        expiryDate,
        description,
      ];
}