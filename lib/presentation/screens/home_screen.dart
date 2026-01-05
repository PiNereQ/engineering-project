import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/dashboard/dashboard_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
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
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                ),
              );
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

            // Handle both DashboardLoaded and DashboardRefreshing
            Dashboard? dashboard;
            bool isRefreshing = false;
            
            if (state is DashboardLoaded) {
              dashboard = state.dashboard;
            } else if (state is DashboardRefreshing) {
              dashboard = state.dashboard;
              isRefreshing = true;
            }

            if (dashboard != null) {
              return RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<DashboardBloc>();
                  bloc.add(RefreshDashboard());
                  // Wait for the bloc to emit a new state
                  await bloc.stream.firstWhere(
                    (state) => state is DashboardLoaded || state is DashboardError,
                  );
                },
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Wybrane specjalnie dla Ciebie!",
                            style: TextStyle(fontFamily: 'Itim', fontSize: 36),
                          ),
                          const SizedBox(height: 24),

                          // Section 1: Favourite Category Coupons
                          if (dashboard.favouriteCategory != null &&
                              dashboard.favouriteCategory!.coupons.isNotEmpty) ...[
                            _DashboardSection(
                              title: 'Ulubiona kategoria: ${dashboard.favouriteCategory!.category.name}',
                              child: _CouponHorizontalList(
                                coupons: dashboard.favouriteCategory!.coupons.take(10).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Section 2: All Favourite Categories Coupons
                          if (dashboard.allFavouriteCategoriesCoupons.isNotEmpty) ...[
                            _DashboardSection(
                              title: 'Kupony z ulubionych kategorii',
                              child: _CouponHorizontalList(
                                coupons: dashboard.allFavouriteCategoriesCoupons.take(10).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Section 3: Favourite Shop Coupons
                          if (dashboard.favouriteShop != null &&
                              dashboard.favouriteShop!.coupons.isNotEmpty) ...[
                            _DashboardSection(
                              title: 'Ulubiony sklep: ${dashboard.favouriteShop!.shop.name}',
                              child: _CouponHorizontalList(
                                coupons: dashboard.favouriteShop!.coupons.take(10).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Section 4: All Favourite Shops Coupons
                          if (dashboard.allFavouriteShopsCoupons.isNotEmpty) ...[
                            _DashboardSection(
                              title: 'Kupony z ulubionych sklepów',
                              child: _CouponHorizontalList(
                                coupons: dashboard.allFavouriteShopsCoupons.take(10).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Section 5: Top Recommended Coupons
                          if (dashboard.topRecommendedCoupons.isNotEmpty) ...[
                            _DashboardSection(
                              title: 'Polecane dla Ciebie',
                              child: _RecommendedCouponHorizontalList(
                                coupons: dashboard.topRecommendedCoupons.take(10).toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 66), // padding for navbar
                        ],
                      ),
                    ),
                    // Show loading indicator overlay when refreshing
                    if (isRefreshing)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x80FFFFFF),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
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

/// Horizontal scrollable list for Coupon objects (standard coupon format)
class _CouponHorizontalList extends StatelessWidget {
  final List<Coupon> coupons;

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
              (coupon) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CouponCardVertical(coupon: coupon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable list for DashboardCoupon objects (recommendation format)
class _RecommendedCouponHorizontalList extends StatelessWidget {
  final List<DashboardCoupon> coupons;

  const _RecommendedCouponHorizontalList({required this.coupons});

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
