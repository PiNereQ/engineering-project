part of 'listed_coupon_bloc.dart';

sealed class ListedCouponState extends Equatable {
  const ListedCouponState();
  
  @override
  List<Object> get props => [];
}

final class ListedCouponInitial extends ListedCouponState {}

final class ListedCouponLoadInProgress extends ListedCouponState {
  final bool isLoading;

  const ListedCouponLoadInProgress({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

class ListedCouponLoadSuccess extends ListedCouponState {
  final ListedCoupon coupon;

  const ListedCouponLoadSuccess({required this.coupon});

  @override
  List<Object> get props => [coupon];
}

class ListedCouponLoadFailure extends ListedCouponState {
  final String message;

  const ListedCouponLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}