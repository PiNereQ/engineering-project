part of 'coupon_map_bloc.dart';

sealed class CouponMapState extends Equatable {
  const CouponMapState();
  
  @override
  List<Object> get props => [];
}

final class CouponMapInitial extends CouponMapState {}

class CouponMapLoading extends CouponMapState {}

class CouponMapLoaded extends CouponMapState {
  final List<Location> locations;

  const CouponMapLoaded({required this.locations});

  @override
  List<Object> get props => [locations];
}

class CouponMapError extends CouponMapState {
  final String message;

  const CouponMapError({required this.message});

  @override
  List<Object> get props => [message];
}