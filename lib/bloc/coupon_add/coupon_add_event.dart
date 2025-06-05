part of 'coupon_add_bloc.dart';

sealed class CouponAddEvent extends Equatable {
  const CouponAddEvent();

  @override
  List<Object> get props => [];
}

class AddCouponOffer extends CouponAddEvent {
  final CouponOffer offer;
  const AddCouponOffer(this.offer);

  @override
  List<Object> get props => [offer];
}

