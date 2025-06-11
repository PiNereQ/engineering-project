part of 'coupon_list_bloc.dart';

sealed class CouponListEvent extends Equatable {
  const CouponListEvent();

  @override
  List<Object> get props => [];
}

class FetchCoupons extends CouponListEvent {}

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
