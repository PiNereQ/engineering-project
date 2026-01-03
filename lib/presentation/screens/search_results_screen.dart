import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proj_inz/bloc/favorite/favorite_bloc.dart';
import 'package:proj_inz/bloc/favorite/favorite_event.dart';
import 'package:proj_inz/bloc/favorite/favorite_state.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_bloc.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/category_model.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_follow_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/search_bar.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchResultsScreen({super.key, this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchFocusNode = FocusNode();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _performSearch(widget.initialQuery!);
    }
    // Focus the search bar after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      context.read<SearchBloc>().add(SearchQuerySubmitted(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(width: 2, color: AppColors.textPrimary),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary,
                      blurRadius: 0,
                      offset: Offset(3, 3),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // przycisk wstecz
                    InkWell(
                      borderRadius: BorderRadius.circular(1000),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: AppColors.textPrimary,
                              blurRadius: 0,
                              offset: Offset(3, 3),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: SvgPicture.asset('assets/icons/back.svg', width: 18, height: 18,),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // search bar
                    Expanded(
                      child: SearchBarWide(
                        hintText: 'Wyszukaj sklep lub kategorię',
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: (query) => _performSearch(query),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // lista wynikow
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchLoaded) {
                    final shops = state.matchedShops;
                    final categories = state.matchedCategories;
              
                    if (shops.isEmpty && categories.isEmpty) {
                      return const Center(
                        child: Text(
                          'Brak wyników',
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }
              
                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        if (categories.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(width: 2, color: AppColors.textPrimary),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.textPrimary,
                                    blurRadius: 0,
                                    offset: Offset(4, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dopasowane kategorie:',
                                    style: TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    children: categories.map((category) {
                                      return CategoryCard(category: category);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
              
                        ...shops.map((item) {
              
                          return ShopCard(shop: item);
                        }),
                      ],
                    );
                  } else if (state is SearchError) {
                    return Center(
                      child: Text(
                        'Błąd: ${state.message}',
                        style: TextStyle(
                          fontFamily: 'Itim',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: const Text(
                      'Wpisz coś, aby rozpocząć wyszukiwanie',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: shop.bgColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                shop.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: shop.nameColor,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Row(
            children: [
              CustomTextButton.small(
                label: 'Pokaż kupony',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create:
                                (context) => CouponListBloc(
                                  context.read<CouponRepository>(),
                                ),
                            child: CouponListScreen(
                              selectedShopId: shop.id,
                              searchShopName: shop.name,
                            ),
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  final isFav =
                      state.favoriteShopIds.contains(shop.id);

                  return CustomFollowButton.small(
                    isHeart: true,
                    isPressed: isFav,
                    onTap: () {
                      context
                          .read<FavoriteBloc>()
                          .add(ToggleShopFavorite(shop.id));
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontFamily: 'Itim',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Row(
            children: [
              CustomTextButton.small(
                label: 'Pokaż kupony',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create:
                                (context) => CouponListBloc(
                                  context.read<CouponRepository>(),
                                ),
                            child: CouponListScreen(
                              selectedCategoryId: category.id,
                              searchCategoryName: category.name,
                            ),
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  final isFav = state.favoriteCategories
                      .any((c) => c.id == category.id);

                  return CustomFollowButton.small(
                    isHeart: true,
                    isPressed: isFav,
                    onTap: () {
                      context.read<FavoriteBloc>().add(
                        ToggleCategoryFavorite(category.id),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
