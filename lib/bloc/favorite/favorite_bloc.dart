import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';
import 'package:proj_inz/data/repositories/favorite_repository.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;

  FavoriteBloc(this.repository) : super(FavoriteState.initial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleShopFavorite>(_onToggleShop);
    on<ToggleCategoryFavorite>(_onToggleCategory);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    final shops = await repository.getFavoriteShopIds();
    final categories = await repository.getFavoriteCategoryIds();

    emit(
      state.copyWith(
        favoriteShopIds: shops.toSet(),
        favoriteCategoryIds: categories.toSet(),
        loading: false,
      ),
    );
  }


  Future<void> _onToggleShop(
    ToggleShopFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final isFav = state.favoriteShopIds.contains(event.shopId);

    if (isFav) {
      await repository.removeShopFromFavorites(event.shopId);
      final updated = Set<String>.from(state.favoriteShopIds)
        ..remove(event.shopId);
      emit(state.copyWith(favoriteShopIds: updated));
    } else {
      await repository.addShopToFavorites(event.shopId);
      final updated = Set<String>.from(state.favoriteShopIds)
        ..add(event.shopId);
      emit(state.copyWith(favoriteShopIds: updated));
    }
  }

  Future<void> _onToggleCategory(
    ToggleCategoryFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final isFav =
        state.favoriteCategoryIds.contains(event.categoryId);

    if (isFav) {
      await repository.removeCategoryFromFavorites(event.categoryId);
      final updated =
          Set<String>.from(state.favoriteCategoryIds)
            ..remove(event.categoryId);
      emit(state.copyWith(favoriteCategoryIds: updated));
    } else {
      await repository.addCategoryToFavorites(event.categoryId);
      final updated =
          Set<String>.from(state.favoriteCategoryIds)
            ..add(event.categoryId);
      emit(state.copyWith(favoriteCategoryIds: updated));
    }
  }
}