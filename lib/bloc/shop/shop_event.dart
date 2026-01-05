part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object> get props => [];
}

class SearchShopsByName extends ShopEvent {
  final String query;
  const SearchShopsByName(this.query);

  @override
  List<Object> get props => [query];
}

class LoadShops extends ShopEvent {}

class SuggestShop extends ShopEvent {
  final String name;
  final String details;

  const SuggestShop(this.name, this.details);

  @override
  List<Object> get props => [name, details];
}
