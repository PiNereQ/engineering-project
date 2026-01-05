import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository shopRepository;

  ShopBloc(this.shopRepository) : super(ShopInitial()) {
    on<LoadShops>((event, emit) async {
      emit(ShopLoading());
      try {
        final shops = await shopRepository.fetchAllShops();
        emit(ShopLoaded(shops));
      } catch (_) {
        emit(ShopError("Nie udało się załadować sklepów."));
      }
    });

    on<SearchShopsByName>((event, emit) async {
      emit(ShopLoading());
      try {
        final shops = await shopRepository.searchShopsByName(event.query);
        emit(ShopLoaded(shops));
      } catch (_) {
        emit(ShopError("Nie udało się wyszukać sklepów."));
      }
    });

    on<SuggestShop>((event, emit) async {
      try {
        emit(ShopLoading());
        await shopRepository.suggestShop(event.name, event.details);
        emit(ShopSuggestionSuccess());
      } catch (_) {
        emit(ShopSuggestionFailure("Nie udało się zaproponować sklepu."));
      }
    });
  }
}
