part of 'coupon_list_bloc.dart';

sealed class CouponListState extends Equatable {
  const CouponListState();
  
  @override
  List<Object> get props => [];
}

final class CouponListInitial extends CouponListState {}

final class CouponListLoadInProgress extends CouponListState {
}

class CouponListLoadSuccess extends CouponListState {
  final List<Coupon> coupons;
  final bool hasMore;

  const CouponListLoadSuccess({required this.coupons, required this.hasMore});

  @override
  List<Object> get props => [coupons];
}

class CouponListLoadFailure extends CouponListState {
  final String message;

  const CouponListLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}