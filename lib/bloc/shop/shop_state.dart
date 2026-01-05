part of 'shop_bloc.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<Shop> shops;

  const ShopLoaded(this.shops);

  @override
  List<Object> get props => [shops];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object> get props => [message];
}

class ShopSuggestionSuccess extends ShopState {}

class ShopSuggestionFailure extends ShopState {
  final String message;

  const ShopSuggestionFailure(this.message);

  @override
  List<Object> get props => [message];
}
