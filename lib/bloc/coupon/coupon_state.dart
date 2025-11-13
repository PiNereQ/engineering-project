part of 'coupon_bloc.dart';

sealed class CouponState extends Equatable {
  const CouponState();
  
  @override
  List<Object> get props => [];
}

final class CouponInitial extends CouponState {}

final class CouponLoadInProgress extends CouponState {
  final bool isLoading;

  const CouponLoadInProgress({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

class CouponLoadSuccess extends CouponState {
  final Coupon coupon;

  const CouponLoadSuccess({required this.coupon});

  @override
  List<Object> get props => [coupon];
}

class CouponLoadFailure extends CouponState {
  final String message;

  const CouponLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}