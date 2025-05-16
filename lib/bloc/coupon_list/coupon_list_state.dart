part of 'coupon_list_bloc.dart';

sealed class CouponListState extends Equatable {
  const CouponListState();
  
  @override
  List<Object> get props => [];
}

final class CouponListInitial extends CouponListState {}

final class CouponListLoading extends CouponListState {
  final bool isLoading;

  const CouponListLoading({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

class CouponListLoaded extends CouponListState {
  final List<Coupon> coupons;

  const CouponListLoaded({required this.coupons});

  @override
  List<Object> get props => [coupons];
}

class CouponListError extends CouponListState {
  final String message;

  const CouponListError({required this.message});

  @override
  List<Object> get props => [message];
}