part of 'owned_coupon_bloc.dart';

sealed class OwnedCouponEvent extends Equatable {
  const OwnedCouponEvent();

  @override
  List<Object> get props => [];
}

class FetchCouponDetails extends OwnedCouponEvent {}