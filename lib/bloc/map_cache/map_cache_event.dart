part of 'map_cache_bloc.dart';

abstract class MapCacheEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapCacheInitialiseRequested extends MapCacheEvent {}

class MapCacheClearRequested extends MapCacheEvent {}

class MapCacheStatusRequested extends MapCacheEvent {}