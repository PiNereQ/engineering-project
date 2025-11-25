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

class CouponMapZoomLevelChanged extends CouponMapEvent {
  final double zoomLevel;

  const CouponMapZoomLevelChanged({required this.zoomLevel});

  @override
  List<Object> get props => [zoomLevel];
}

class CouponMapSearchExecuted extends CouponMapEvent {
  const CouponMapSearchExecuted();
}

class CouponMapLocationSelected extends CouponMapEvent {
  final String shopLocationId;
  final String shopId;

  const CouponMapLocationSelected({required this.shopLocationId, required this.shopId});

  @override
  List<Object> get props => [shopLocationId, shopId];
}

class CouponMapLocationCouponsLoaded extends CouponMapEvent {
  final String shopLocationId;
  final String shopId;

  const CouponMapLocationCouponsLoaded({required this.shopLocationId, required this.shopId});

  @override
  List<Object> get props => [shopLocationId, shopId];
}

class CouponMapLocationCleared extends CouponMapEvent {
  const CouponMapLocationCleared();
}