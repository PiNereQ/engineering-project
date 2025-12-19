part of 'owned_coupon_bloc.dart';

sealed class OwnedCouponState extends Equatable {
  const OwnedCouponState();
  
  @override
  List<Object> get props => [];
}

final class OwnedCouponInitial extends OwnedCouponState {}

final class OwnedCouponLoadInProgress extends OwnedCouponState {
  final bool isLoading;

  const OwnedCouponLoadInProgress({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

class OwnedCouponLoadSuccess extends OwnedCouponState {
  final Coupon coupon;

  const OwnedCouponLoadSuccess({required this.coupon});

  @override
  List<Object> get props => [coupon];
}

class OwnedCouponLoadFailure extends OwnedCouponState {
  final String message;

  const OwnedCouponLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}
