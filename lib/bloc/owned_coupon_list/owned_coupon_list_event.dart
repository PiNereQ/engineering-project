part of 'owned_coupon_list_bloc.dart';

sealed class OwnedCouponListEvent extends Equatable {
  const OwnedCouponListEvent();

  @override
  List<Object> get props => [];
}

class FetchCoupons extends OwnedCouponListEvent {}

class FetchMoreCoupons extends OwnedCouponListEvent {}

class RefreshCoupons extends OwnedCouponListEvent {}