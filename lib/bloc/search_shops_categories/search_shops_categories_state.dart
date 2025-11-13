import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/category_model.dart';
import 'package:proj_inz/data/models/shop_model.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Shop> matchedShops;
  final List<Category> matchedCategories;

  SearchLoaded({
    required this.matchedShops,
    required this.matchedCategories,
  });

  @override
  List<Object?> get props => [matchedShops, matchedCategories];
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
