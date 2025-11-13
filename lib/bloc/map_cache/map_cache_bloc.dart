import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/map_cache_repository.dart';

part 'map_cache_event.dart';
part 'map_cache_state.dart';

class MapCacheBloc extends Bloc<MapCacheEvent, MapCacheState> {
  final MapCacheRepository mapCacheRepository;

  MapCacheBloc({required this.mapCacheRepository}) : super(MapCacheInitial()) {
    on<MapCacheInitialiseRequested>(_onInitializeRequested);
    on<MapCacheClearRequested>(_onClearRequested);
    on<MapCacheStatusRequested>(_onStatusRequested);
  }

  void _onInitializeRequested(
      MapCacheInitialiseRequested event, Emitter<MapCacheState> emit) async {
    emit(MapCacheInitialiseInProgress());
    try {
      await mapCacheRepository.initialize();
      emit(MapCacheInitialisedSuccess());
    } catch (e) {
      emit(MapCacheInitialiseError(errorMessage: e.toString()));
    }
  }

  void _onClearRequested(
      MapCacheClearRequested event, Emitter<MapCacheState> emit) async {
    emit(MapCacheClearInProgress());
    try {
      await mapCacheRepository.clearCache();
      emit(MapCacheClearSuccess());
    } catch (e) {
      emit(MapCacheClearError(errorMessage: e.toString()));
    }
  }

  void _onStatusRequested(
      MapCacheStatusRequested event, Emitter<MapCacheState> emit) async {
    emit(MapCacheGetStatusInProgress());
    try {
      final cacheSize = await mapCacheRepository.getCacheSize();
      final cacheSizeFormatted = await mapCacheRepository.getCacheSizeFormatted();
      final tilesCount = await mapCacheRepository.getCachedTilesCount();
      
      emit(MapCacheGetStatusSuccess(
        cacheSize: cacheSize,
        cacheSizeFormatted: cacheSizeFormatted,
        tilesCount: tilesCount,
      ));
    } catch (e) {
      emit(MapCacheGetStatusError(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    mapCacheRepository.dispose();
    return super.close();
  }
}