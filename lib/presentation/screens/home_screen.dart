import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/dashboard/dashboard_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/dashboard_model.dart';
import 'package:proj_inz/data/repositories/dashboard_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              DashboardBloc(DashboardRepository())..add(FetchDashboard()),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Błąd ładowania',
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(FetchDashboard());
                      },
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hej!\nOto Twój dashboard.",
                        style: TextStyle(fontFamily: 'Itim', fontSize: 36),
                      ),
                      const SizedBox(height: 24),

                      // Favourite Category Section
                      _DashboardSection(
                        title: 'Ulubiona kategoria',
                        child:
                            state.dashboard.favouriteCategory != null
                                ? _FavouriteCategoryTile(
                                  category: state.dashboard.favouriteCategory!,
                                )
                                : const _EmptyTile(
                                  message: 'Brak ulubionych kategorii',
                                ),
                      ),
                      const SizedBox(height: 16),

                      // All Favourite Categories Section
                      if (state
                          .dashboard
                          .allFavouriteCategories
                          .isNotEmpty) ...[
                        _DashboardSection(
                          title: 'Wszystkie ulubione kategorie',
                          child: _HorizontalList(
                            itemCount:
                                state.dashboard.allFavouriteCategories.length,
                            itemBuilder: (context, index) {
                              return _FavouriteCategoryTile(
                                category:
                                    state
                                        .dashboard
                                        .allFavouriteCategories[index],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Favourite Shop Section
                      _DashboardSection(
                        title: 'Ulubiony sklep',
                        child:
                            state.dashboard.favouriteShop != null
                                ? _FavouriteShopTile(
                                  shop: state.dashboard.favouriteShop!,
                                )
                                : const _EmptyTile(
                                  message: 'Brak ulubionych sklepów',
                                ),
                      ),
                      const SizedBox(height: 16),

                      // All Favourite Shops Section
                      if (state.dashboard.allFavouriteShops.isNotEmpty) ...[
                        _DashboardSection(
                          title: 'Wszystkie ulubione sklepy',
                          child: _HorizontalList(
                            itemCount: state.dashboard.allFavouriteShops.length,
                            itemBuilder: (context, index) {
                              return _FavouriteShopTile(
                                shop: state.dashboard.allFavouriteShops[index],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Top Recommended Coupons Section
                      _DashboardSection(
                        title: 'Polecane kupony',
                        child:
                            state.dashboard.topRecommendedCoupons.isNotEmpty
                                ? _CouponHorizontalList(
                                  coupons:
                                      state.dashboard.topRecommendedCoupons,
                                )
                                : const _EmptyTile(
                                  message: 'Brak polecanych kuponów',
                                ),
                      ),

                      const SizedBox(height: 66), // padding for navbar
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Itim',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _HorizontalList({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Horizontal scrollable list for coupons using CouponCardVertical (same as map screen)
class _CouponHorizontalList extends StatelessWidget {
  final List<DashboardCoupon> coupons;

  const _CouponHorizontalList({required this.coupons});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          children: [
            ...coupons.map(
              (dashboardCoupon) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CouponCardVertical(coupon: dashboardCoupon.toCoupon()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaseTile extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const _BaseTile({required this.child, this.width = 200, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.textPrimary, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
      ),
      child: child,
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String message;

  const _EmptyTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      width: double.infinity,
      height: 80,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Itim',
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FavouriteCategoryTile extends StatelessWidget {
  final FavouriteCategory category;

  const _FavouriteCategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category, size: 28, color: AppColors.primaryButton),
          const SizedBox(height: 8),
          Text(
            category.name.isNotEmpty
                ? category.name
                : 'Kategoria ${category.id}',
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (category.count > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Zakupy: ${category.count}',
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavouriteShopTile extends StatelessWidget {
  final FavouriteShop shop;

  const _FavouriteShopTile({required this.shop});

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store, size: 28, color: AppColors.primaryButton),
          const SizedBox(height: 8),
          Text(
            shop.name.isNotEmpty ? shop.name : 'Sklep ${shop.id}',
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (shop.count > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Zakupy: ${shop.count}',
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
