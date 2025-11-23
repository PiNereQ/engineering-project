part of 'coupon_map_bloc.dart';

sealed class CouponMapEvent extends Equatable {
  const CouponMapEvent();

  @override
  List<Object> get props => [];
}

class LoadLocationsInBounds extends CouponMapEvent {
  final LatLngBounds bounds;

  const LoadLocationsInBounds({required this.bounds});

  @override
  List<Object> get props => [bounds];
}

class CouponMapPositionChanged extends CouponMapEvent {
  final double zoomLevel;

  const CouponMapPositionChanged({required this.zoomLevel});

  @override
  List<Object> get props => [zoomLevel];
}

class CouponMapSearchExecuted extends CouponMapEvent {
  const CouponMapSearchExecuted();
}

class CouponMapLocationSelected extends CouponMapEvent {
  final String locationId;

  const CouponMapLocationSelected({required this.locationId});

  @override
  List<Object> get props => [locationId];
}

class CouponMapLocationCleared extends CouponMapEvent {
  const CouponMapLocationCleared();
}