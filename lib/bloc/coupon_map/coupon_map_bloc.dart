import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/repositories/map_repository.dart';
import 'package:flutter_map/flutter_map.dart';

part 'coupon_map_event.dart';
part 'coupon_map_state.dart';

class CouponMapBloc extends Bloc<CouponMapEvent, CouponMapState> {
  final MapRepository mapRepository;

  CouponMapBloc({required this.mapRepository}) : super(CouponMapInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<LoadLocationsInBounds>(_onLoadLocationsInBounds);
  }

  Future<void> _onLoadLocations(LoadLocations event, Emitter<CouponMapState> emit) async {
    emit(CouponMapLoading());
    try {
      final locations = await mapRepository.fetchLocations();
      emit(CouponMapLoaded(locations: locations));
    } catch (e) {
      emit(CouponMapError(message: e.toString()));
    }
  }

  Future<void> _onLoadLocationsInBounds(LoadLocationsInBounds event, Emitter<CouponMapState> emit) async {
    emit(CouponMapLoading());
    try {
      final locations = await mapRepository.fetchLocationsInBounds(event.bounds);
      emit(CouponMapLoaded(locations: locations));
    } catch (e) {
      emit(CouponMapError(message: e.toString()));
    }
  }
}

