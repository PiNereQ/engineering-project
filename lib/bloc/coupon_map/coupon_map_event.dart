part of 'coupon_map_bloc.dart';

sealed class CouponMapEvent extends Equatable {
  const CouponMapEvent();

  @override
  List<Object> get props => [];
}

class LoadLocations extends CouponMapEvent {}

class LoadLocationsInBounds extends CouponMapEvent {
  final LatLngBounds bounds;

  const LoadLocationsInBounds({required this.bounds});

  @override
  List<Object> get props => [bounds];
}