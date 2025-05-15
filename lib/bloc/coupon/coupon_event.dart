part of 'coupon_bloc.dart';

sealed class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object> get props => [];
}

class FetchCouponDetails extends CouponEvent {}