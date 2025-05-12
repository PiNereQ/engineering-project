part of 'coupon_bloc.dart';

sealed class CouponState extends Equatable {
  const CouponState();
  
  @override
  List<Object> get props => [];
}

final class CouponInitial extends CouponState {}

class CouponLoaded extends CouponState {
  final List<Coupon> coupons;

  const CouponLoaded({required this.coupons});

  @override
  List<Object> get props => [coupons];
}
