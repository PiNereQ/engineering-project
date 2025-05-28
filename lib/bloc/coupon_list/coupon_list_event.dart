part of 'coupon_list_bloc.dart';

sealed class CouponListEvent extends Equatable {
  const CouponListEvent();

  @override
  List<Object> get props => [];
}

class FetchCoupons extends CouponListEvent {}

class FetchMoreCoupons extends CouponListEvent {}