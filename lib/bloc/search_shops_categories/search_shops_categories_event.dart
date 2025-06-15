import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchQuerySubmitted extends SearchEvent {
  final String query;

  SearchQuerySubmitted(this.query);

  @override
  List<Object?> get props => [query];
}
