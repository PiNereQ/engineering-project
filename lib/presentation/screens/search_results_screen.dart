import 'package:flutter/material.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_bloc.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Wyniki dla hasła: $query',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
      ),
      body: Column(
        children: [
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
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: categories.map((category) {
                                    return Chip(
                                      label: Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      backgroundColor: AppColors.secondaryButton,
                                      side: const BorderSide(color: AppColors.textPrimary, width: 1),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      ...shops.map((item) {
                        final shopColor = Color(item.bgColor);

                        return Container(
                          width: double.infinity,
                          height: 65,
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
                                width: 110,
                                height: 45,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: shopColor,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.surface,
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(minHeight: 36),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider(
                                                create: (context) => CouponListBloc(
                                                  context.read<CouponRepository>(),
                                                )..add(FetchCoupons(shopId: item.id,)),
                                                child: CouponListScreen(
                                                  selectedShopId: item.id,
                                                  searchShopName: item.name,
                                                  ),
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(1000),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'Pokaż kupony',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontFamily: 'Itim',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 36,
                                      height: 36,
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
                                            offset: Offset(2, 2),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/favorite.svg',
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                } else if (state is SearchError) {
                  return Center(child: Text('Błąd: ${state.message}'));
                }
                return const Center(child: Text('Wpisz zapytanie'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
