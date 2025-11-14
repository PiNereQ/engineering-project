part of 'map_cache_bloc.dart';

abstract class MapCacheState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapCacheInitial extends MapCacheState {}

class MapCacheInitialiseInProgress extends MapCacheState {}

class MapCacheInitialisedSuccess extends MapCacheState {}

class MapCacheInitialiseError extends MapCacheState {
  final String errorMessage;

  MapCacheInitialiseError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class MapCacheClearInProgress extends MapCacheState {}

class MapCacheClearSuccess extends MapCacheState {}

class MapCacheClearError extends MapCacheState {
  final String errorMessage;

  MapCacheClearError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class MapCacheGetStatusInProgress extends MapCacheState {}

class MapCacheGetStatusSuccess extends MapCacheState {
  final int cacheSize;
  final String cacheSizeFormatted;
  final int tilesCount;

  MapCacheGetStatusSuccess({
    required this.cacheSize,
    required this.cacheSizeFormatted,
    required this.tilesCount,
  });

  @override
  List<Object?> get props => [cacheSize, cacheSizeFormatted, tilesCount];
}

class MapCacheGetStatusError extends MapCacheState {
  final String errorMessage;

  MapCacheGetStatusError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}