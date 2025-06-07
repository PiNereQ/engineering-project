part of 'coupon_list_bloc.dart';

sealed class CouponListEvent extends Equatable {
  const CouponListEvent();

  @override
  List<Object> get props => [];
}

class FetchCoupons extends CouponListEvent {}

class FetchMoreCoupons extends CouponListEvent {}

class RefreshCoupons extends CouponListEvent {}

class ApplyCouponFilter extends CouponListEvent {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final double? minPrice;
  final double? maxPrice;
  final num? minReputation;

  ApplyCouponFilter({
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.minPrice,
    this.maxPrice,
    this.minReputation
  });
}

class ClearCouponFilter extends CouponListEvent {}