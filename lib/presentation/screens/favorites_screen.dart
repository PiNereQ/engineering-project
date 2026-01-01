import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/favorite/favorite_bloc.dart';
import 'package:proj_inz/bloc/favorite/favorite_state.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/models/category_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/data/repositories/category_repository.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopRepo = context.read<ShopRepository>();
    final categoryRepo = context.read<CategoryRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ulubione',
          style: TextStyle(
            fontFamily: 'Itim',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteShopIds = state.favoriteShopIds.toList();
          final favoriteCategories = state.favoriteCategories;

          if (favoriteShopIds.isEmpty && favoriteCategories.isEmpty) {
            return const Center(
              child: Text(
                'Nie masz jeszcze ulubionych sklepów ani kategorii',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (favoriteShopIds.isNotEmpty) ...[
                const Text(
                  'Ulubione sklepy',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                ...favoriteShopIds.map(
                  (shopId) => FutureBuilder<Shop>(
                    future: shopRepo.fetchShopById(shopId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        );
                      }

                      final shop = snapshot.data!;
                      return _ShopTile(shop: shop);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                if (favoriteCategories.isNotEmpty) ...[
                  const Text(
                    'Ulubione kategorie',
                    style: TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...favoriteCategories.map(
                    (category) => _CategoryTile(category: category),
                  ),
                ],
              ],
            ]
          );
        },
      ),
    );
  }
}

class _ShopTile extends StatelessWidget {
  final Shop shop;

  const _ShopTile({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            shop.name,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
            ),
          ),
          CustomTextButton.small(
            label: 'Pokaż kupony',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CouponListScreen(
                    selectedShopId: shop.id,
                    searchShopName: shop.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category.name,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
            ),
          ),
          CustomTextButton.small(
            label: 'Pokaż kupony',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CouponListScreen(
                    selectedCategoryId: category.id,
                    searchCategoryName: category.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}