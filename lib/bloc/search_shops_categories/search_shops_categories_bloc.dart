import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_shops_categories_event.dart';
import 'search_shops_categories_state.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {

  final ShopRepository shopRepository;
  // final CategoryRepository categoryRepository;

  SearchBloc({
    required this.shopRepository,
    // required this.categoryRepository,
  }) : super(SearchInitial()) {
    on<SearchQuerySubmitted>(_onSearchQuerySubmitted);
  }

  Future<void> _onSearchQuerySubmitted(SearchQuerySubmitted event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      // Tu wykonaj wyszukiwanie sklepów i kategorii (przykład)
      final shops = await shopRepository.searchShopsByName(event.query);
      // final categories = await categoryRepository.searchCategoriesByName(event.query);

      // Możesz połączyć wyniki, np. w jedną listę:
      final results = [...shops, /*...categories*/];

      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError('Failed to search: ${e.toString()}'));
    }
  }
}
