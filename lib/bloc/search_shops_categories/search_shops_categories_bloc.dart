import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_shops_categories_event.dart';
import 'search_shops_categories_state.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/data/repositories/category_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ShopRepository shopRepository;
  final CategoryRepository categoryRepository;

  SearchBloc({
    required this.shopRepository,
    required this.categoryRepository,
  }) : super(SearchInitial()) {
    on<SearchQuerySubmitted>(_onSearchQuerySubmitted);
  }

  Future<void> _onSearchQuerySubmitted(SearchQuerySubmitted event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final shopsByName = await shopRepository.searchShopsByName(event.query);

      final categories = await categoryRepository.searchCategoriesByName(event.query);

      // pobieranie sklepow dla kazdej pasujacej kategorii i laczenie
      List<Shop> shopsByCategory = [];
      for (final category in categories) {
        final shops = await categoryRepository.fetchShopsByCategory(category);
        shopsByCategory.addAll(shops);
      }

      // usuwanie duplikatow
      final uniqueShopsByCategory = {
        for (var shop in shopsByCategory) shop.id: shop,
      }.values.toList();

      // laczenie wynikow z wyszukiwania po nazwie i po kategorii
      final allShopsMap = {
        for (var shop in [...shopsByName, ...uniqueShopsByCategory]) shop.id: shop,
      };

      // nowy stan z rozdzielonymi danymi
      emit(SearchLoaded(
        matchedShops: allShopsMap.values.toList(),
        matchedCategories: categories,
      ));
    } catch (e) {
      emit(SearchError('Failed to search: ${e.toString()}'));
    }
  }
}
