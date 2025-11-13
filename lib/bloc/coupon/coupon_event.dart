part of 'coupon_bloc.dart';

sealed class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object> get props => [];
}

class FetchCouponDetails extends CouponEvent {}

class BuyCouponRequested extends CouponEvent {
  final String couponId;
  final String userId;

  const BuyCouponRequested({
    required this.couponId,
    required this.userId,
  });

  @override
  List<Object> get props => [couponId];
}