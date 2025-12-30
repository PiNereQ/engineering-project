part of 'coupon_list_bloc.dart';

sealed class CouponListEvent extends Equatable {
  const CouponListEvent();

  @override
  List<Object?> get props => [];
}


class FetchCoupons extends CouponListEvent {
  final String? shopId;
  final String? categoryId;
  final bool? filterByShop; // true = shop, false = category, null = none
  final String userId;

  const FetchCoupons({this.shopId, this.categoryId, this.filterByShop, required this.userId});

  @override
  List<Object?> get props => [shopId, categoryId, filterByShop, userId];
}

class FetchMoreCoupons extends CouponListEvent {}

class RefreshCoupons extends CouponListEvent {}

class ApplyCouponFilters extends CouponListEvent {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final double? minPrice;
  final double? maxPrice;
  final int? minReputation;

  const ApplyCouponFilters({
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.minPrice,
    this.maxPrice,
    this.minReputation
  });
}

class ClearCouponFilters extends CouponListEvent {}

class ReadCouponFilters extends CouponListEvent {}

class LeaveCouponFilterPopUp extends CouponListEvent {}


class ApplyCouponOrdering extends CouponListEvent {
  final Ordering ordering;

  const ApplyCouponOrdering(this.ordering);
}

class ReadCouponOrdering extends CouponListEvent {}

class LeaveCouponSortPopUp extends CouponListEvent {}

class ToggleCouponSaved extends CouponListEvent {
  final String couponId;
  final bool isSaved;

  const ToggleCouponSaved({
    required this.couponId,
    required this.isSaved,
  });

  @override
  List<Object> get props => [couponId, isSaved];
}