part of 'saved_coupon_list_bloc.dart';

sealed class SavedCouponListState extends Equatable {
  const SavedCouponListState();

  @override
  List<Object?> get props => [];
}

class SavedCouponListInitial extends SavedCouponListState {}

class SavedCouponListLoadInProgress extends SavedCouponListState {}

class SavedCouponListLoadSuccess extends SavedCouponListState {
  final List<Coupon> coupons;

  const SavedCouponListLoadSuccess({required this.coupons});

  @override
  List<Object?> get props => [coupons];
}

class SavedCouponListLoadEmpty extends SavedCouponListState {}

class SavedCouponListLoadFailure extends SavedCouponListState {
  final String message;

  const SavedCouponListLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}