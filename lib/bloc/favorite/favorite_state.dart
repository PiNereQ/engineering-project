class FavoriteState {
  final Set<String> favoriteShopIds;
  final Set<String> favoriteCategoryIds;
  final bool loading;

  const FavoriteState({
    required this.favoriteShopIds,
    required this.favoriteCategoryIds,
    required this.loading,
  });

  factory FavoriteState.initial() => const FavoriteState(
        favoriteShopIds: {},
        favoriteCategoryIds: {},
        loading: true,
      );

  FavoriteState copyWith({
    Set<String>? favoriteShopIds,
    Set<String>? favoriteCategoryIds,
    bool? loading,
  }) {
    return FavoriteState(
      favoriteShopIds: favoriteShopIds ?? this.favoriteShopIds,
      favoriteCategoryIds:
          favoriteCategoryIds ?? this.favoriteCategoryIds,
      loading: loading ?? this.loading,
    );
  }
}