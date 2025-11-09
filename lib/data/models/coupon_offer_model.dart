import 'package:equatable/equatable.dart';

class CouponOffer extends Equatable {
  final double reduction;
  final bool reductionIsPercentage;
  final double price;

  final String code;
  
  final bool hasLimits;
  final bool worksOnline;
  final bool worksInStore;
  final DateTime expiryDate;
  final String? description;

  final String shopId;

  const CouponOffer({
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,
    required this.code,
    required this.hasLimits,
    required this.worksOnline,
    required this.worksInStore,
    required this.expiryDate,
    this.description,

    required this.shopId,
  });

  @override
  List<Object?> get props => [
    reduction,
    reductionIsPercentage,
    price,
    code,
    shopId,
    hasLimits,
    worksOnline,
    worksInStore,
    expiryDate,
  ];
}