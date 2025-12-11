part of 'owned_coupon_list_bloc.dart';

sealed class OwnedCouponListEvent extends Equatable {
  const OwnedCouponListEvent();

  @override
  List<Object> get props => [];
}

class FetchCoupons extends OwnedCouponListEvent {
  final String userId;
  
  const FetchCoupons({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class FetchMoreCoupons extends OwnedCouponListEvent {}

class RefreshCoupons extends OwnedCouponListEvent {}