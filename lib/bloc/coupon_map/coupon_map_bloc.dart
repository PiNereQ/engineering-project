import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/repositories/map_repository.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:flutter_map/flutter_map.dart';

part 'coupon_map_event.dart';
part 'coupon_map_state.dart';

class CouponMapBloc extends Bloc<CouponMapEvent, CouponMapState> {
  final MapRepository mapRepository;
  final CouponRepository couponRepository;

  CouponMapBloc({required this.mapRepository, required this.couponRepository}) : super(const CouponMapState()) {
    on<LoadLocationsInBounds>(_onLoadLocationsInBounds);
    on<CouponMapPositionChanged>(_onPositionChanged);
    on<CouponMapSearchExecuted>(_onSearchExecuted);
    on<CouponMapLocationSelected>(_onLocationSelected);
    on<CouponMapLocationCleared>(_onLocationCleared);
  }

  Future<void> _onLoadLocationsInBounds(
    LoadLocationsInBounds event,
    Emitter<CouponMapState> emit,
  ) async {
    emit(state.copyWith(status: CouponMapStatus.loading));
    try {
      final locations = await mapRepository.fetchLocationsInBounds(
        event.bounds,
      );
      emit(
        state.copyWith(
          status: CouponMapStatus.success,
          locations: locations,
          showSearchButton: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CouponMapStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onPositionChanged(
    CouponMapPositionChanged event,
    Emitter<CouponMapState> emit,
  ) {
    final shouldShowZoomTip = event.zoomLevel < 11;
    final shouldShowSearchButton = event.zoomLevel >= 11;

    emit(
      state.copyWith(
        showSearchButton: shouldShowSearchButton,
        showZoomTip: shouldShowZoomTip,
      ),
    );
  }

  void _onSearchExecuted(
    CouponMapSearchExecuted event,
    Emitter<CouponMapState> emit,
  ) {
    emit(state.copyWith(showSearchButton: false));
  }

  Future<void> _onLocationSelected(
    CouponMapLocationSelected event,
    Emitter<CouponMapState> emit,
  ) async {
    emit(state.copyWith(
      selectedShopLocationId: event.shopLocationId,
      selectedShopLocationCoupons: const [],
      status: CouponMapStatus.loading,
    ));

    try {
      final coupons = await couponRepository.fetchThreeCouponsForShop(event.shopLocationId);
      emit(state.copyWith(
        status: CouponMapStatus.success,
        selectedShopLocationCoupons: coupons,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CouponMapStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onLocationCleared(
    CouponMapLocationCleared event,
    Emitter<CouponMapState> emit,
  ) {
    emit(state.copyWith(selectedShopLocationId: null));
  }
}
