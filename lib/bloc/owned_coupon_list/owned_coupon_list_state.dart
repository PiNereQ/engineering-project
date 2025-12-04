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