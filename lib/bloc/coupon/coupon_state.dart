part of 'coupon_bloc.dart';

sealed class CouponState extends Equatable {
  const CouponState();
  
  @override
  List<Object> get props => [];
}

final class CouponInitial extends CouponState {}

final class CouponLoading extends CouponState {
  final bool isLoading;

  const CouponLoading({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

class CouponLoaded extends CouponState {
  final List<Coupon> coupons;

  const CouponLoaded({required this.coupons});

  @override
  List<Object> get props => [coupons];
}

class CouponError extends CouponState {
  final String message;

  const CouponError({required this.message});

  @override
  List<Object> get props => [message];
}