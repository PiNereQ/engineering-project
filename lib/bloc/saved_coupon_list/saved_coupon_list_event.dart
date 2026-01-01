part of 'saved_coupon_list_bloc.dart';

sealed class SavedCouponListEvent extends Equatable {
  const SavedCouponListEvent();

  @override
  List<Object?> get props => [];
}

class FetchSavedCoupons extends SavedCouponListEvent {
  final String userId;
  const FetchSavedCoupons({required this.userId});

  @override
  List<Object> get props => [userId];
}

class RefreshSavedCoupons extends SavedCouponListEvent {
  final String userId;
  const RefreshSavedCoupons({required this.userId});

  @override
  List<Object> get props => [userId];
}