part of 'owned_coupon_list_bloc.dart';

sealed class OwnedCouponListState extends Equatable {
  const OwnedCouponListState();
  
  @override
  List<Object> get props => [];
}

final class OwnedCouponListInitial extends OwnedCouponListState {}

final class OwnedCouponListLoadInProgress extends OwnedCouponListState {}

class OwnedCouponListLoadSuccess extends OwnedCouponListState {
  final List<OwnedCoupon> coupons;
  final bool hasMore;

  const OwnedCouponListLoadSuccess({required this.coupons, required this.hasMore});

  @override
  List<Object> get props => [coupons];
}

class OwnedCouponListLoadFailure extends OwnedCouponListState {
  final String message;

  const OwnedCouponListLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

final class OwnedCouponListLoadEmpty extends OwnedCouponListState {}

class OwnedCouponFilterRead extends OwnedCouponListState {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final double? minPrice;
  final double? maxPrice;
  final bool? onlyUsed;
  final String? shopId;

  const OwnedCouponFilterRead({
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.minPrice,
    this.maxPrice,
    this.onlyUsed,
    this.shopId,
  });
}

class OwnedCouponOrderingRead extends OwnedCouponListState {
  final OwnedCouponsOrdering ordering;
  const OwnedCouponOrderingRead(this.ordering);

  @override
  List<Object> get props => [ordering];
}