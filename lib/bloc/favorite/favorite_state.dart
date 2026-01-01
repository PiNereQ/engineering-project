import 'package:proj_inz/data/models/category_model.dart';

class FavoriteState {
  final Set<String> favoriteShopIds;
  final List<Category> favoriteCategories;
  final bool loading;

  const FavoriteState({
    required this.favoriteShopIds,
    required this.favoriteCategories,
    required this.loading,
  });

  factory FavoriteState.initial() => const FavoriteState(
        favoriteShopIds: {},
        favoriteCategories: [],
        loading: true,
      );

  FavoriteState copyWith({
    Set<String>? favoriteShopIds,
    List<Category>? favoriteCategories,
    bool? loading,
  }) {
    return FavoriteState(
      favoriteShopIds: favoriteShopIds ?? this.favoriteShopIds,
      favoriteCategories:
          favoriteCategories ?? this.favoriteCategories,
      loading: loading ?? this.loading,
    );
  }
}