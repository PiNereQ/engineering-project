part of 'saved_coupon_list_bloc.dart';

sealed class SavedCouponListState extends Equatable {
  const SavedCouponListState();

  @override
  List<Object?> get props => [];
}

class SavedCouponListInitial extends SavedCouponListState {}

class SavedCouponListLoadInProgress extends SavedCouponListState {
  final List<Coupon> coupons;
  const SavedCouponListLoadInProgress({this.coupons = const []});

  @override
  List<Object?> get props => [coupons];
}

class SavedCouponListLoadSuccess extends SavedCouponListState {
  final List<Coupon> coupons;
  final bool hasMore;

  const SavedCouponListLoadSuccess({
    required this.coupons,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [coupons, hasMore];
}

class SavedCouponListLoadEmpty extends SavedCouponListState {}

class SavedCouponListLoadFailure extends SavedCouponListState {
  final String message;
  const SavedCouponListLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}