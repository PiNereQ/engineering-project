import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/map_repository.dart';

part 'coupon_map_event.dart';
part 'coupon_map_state.dart';

class CouponMapBloc extends Bloc<CouponMapEvent, CouponMapState> {
  final MapRepository mapRepository;

  CouponMapBloc({required this.mapRepository}) : super(CouponMapInitial()) {
    on<LoadLocations>(_onLoadLocations);
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
}

