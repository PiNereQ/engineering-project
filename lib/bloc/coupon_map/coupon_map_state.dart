part of 'coupon_map_bloc.dart';

sealed class CouponMapState extends Equatable {
  const CouponMapState();
  
  @override
  List<Object> get props => [];
}

final class CouponMapInitial extends CouponMapState {}

class CouponMapShopLocationLoadInProgress extends CouponMapState {}

class CouponMapShopLocationLoadSuccess extends CouponMapState {
  final List<Location> locations;

  const CouponMapShopLocationLoadSuccess({required this.locations});

  @override
  List<Object> get props => [locations];
}

class CouponMapShopLoadError extends CouponMapState {
  final String message;

  const CouponMapShopLoadError({required this.message});

  @override
  List<Object> get props => [message];
}