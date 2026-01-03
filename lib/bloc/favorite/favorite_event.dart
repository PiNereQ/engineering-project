abstract class FavoriteEvent {}

class LoadFavorites extends FavoriteEvent {}

class ToggleShopFavorite extends FavoriteEvent {
  final String shopId;
  ToggleShopFavorite(this.shopId);
}

class ToggleCategoryFavorite extends FavoriteEvent {
  final String categoryId;
  ToggleCategoryFavorite(this.categoryId);
}