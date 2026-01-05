import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/bloc/favorite/favorite_bloc.dart';
import 'package:proj_inz/bloc/favorite/favorite_event.dart';
import 'package:proj_inz/bloc/favorite/favorite_state.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/models/category_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/presentation/screens/add_screen.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_follow_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool showShops = true;

  @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(LoadFavorites());
  }
  
  @override
  Widget build(BuildContext context) {
    final shopRepo = context.read<ShopRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _FavoritesToolbar(
              showShops: showShops,
              onSelectShops: () => setState(() => showShops = true),
              onSelectCategories: () => setState(() => showShops = false),
            ),

            BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                if (state.loading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }

                // shops
                if (showShops) {
                  if (state.favoriteShopIds.isEmpty) {
                    return const SliverFillRemaining(
                      child: _EmptyFavoritesState(
                        text:
                            "Nie masz jeszcze ulubionych sklepów.\n"
                            "Możesz dodać je, wyszukując sklep "
                            "w zakładce \"Kupony\" i klikając ikonę serca.",
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final shopId = state.favoriteShopIds.elementAt(index);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FutureBuilder<Shop>(
                            future: shopRepo.fetchShopById(shopId),
                            builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 86);
                            }
                              return _ShopTile(shop: snapshot.data!);
                            },
                          ),
                        );
                      },
                      childCount: state.favoriteShopIds.length,
                    ),
                  );
                }

                // categories
                if (state.favoriteCategories.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyFavoritesState(
                      text:
                          "Nie masz jeszcze ulubionych kategorii.\n"
                          "Możesz dodać je, wyszukując kategorię "
                          "w zakładce \"Kupony\" i klikając ikonę serca.",
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _CategoryTile(
                          category: state.favoriteCategories[index],
                        ),
                      );
                    },
                    childCount: state.favoriteCategories.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopTile extends StatelessWidget {
  final Shop shop;

  const _ShopTile({required this.shop});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFav = state.favoriteShopIds.contains(shop.id);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: null,
          child: Container(
            height: 70,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                // logo
                Container(
                  width: 140,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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

                // heart
                CustomFollowButton.small(
                  isHeart: true,
                  isPressed: isFav,
                  onTap: () async {
                    if (isFav) {
                      final confirm = await showRemoveFavoriteDialog(
                        context,
                        title: 'Usuń z ulubionych',
                        content:
                            'Czy na pewno chcesz usunąć ten sklep z ulubionych?',
                      );

                      if (confirm == true) {
                        context
                            .read<FavoriteBloc>()
                            .add(ToggleShopFavorite(shop.id));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFav = state.favoriteCategories
            .any((c) => c.id == category.id);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: null,
          child: Container(
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
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 18,
                    ),
                  ),
                ),
                CustomFollowButton.small(
                  isHeart: true,
                  isPressed: isFav,
                  onTap: () async {
                    if (isFav) {
                      final confirm = await showRemoveFavoriteDialog(
                        context,
                        title: 'Usuń z ulubionych',
                        content:
                            'Czy na pewno chcesz usunąć tę kategorię z ulubionych?',
                      );

                      if (confirm == true) {
                        context.read<FavoriteBloc>().add(
                          ToggleCategoryFavorite(category.id),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FavoritesToolbar extends StatelessWidget {
  final bool showShops;
  final VoidCallback onSelectShops;
  final VoidCallback onSelectCategories;

  const _FavoritesToolbar({
    required this.showShops,
    required this.onSelectShops,
    required this.onSelectCategories,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 130,
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Container(
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.textPrimary,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: CustomTextButton.small(
                          label: 'Sklepy',
                          icon: const Icon(Icons.store_rounded, size: 18),
                          backgroundColor: showShops
                              ? AppColors.primaryButton
                              : AppColors.surface,
                          onTap: () {
                            if (!showShops) {
                              onSelectShops();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: CustomTextButton.small(
                          label: 'Kategorie',
                          icon: const Icon(Icons.segment_rounded, size: 18),
                          backgroundColor: !showShops
                              ? AppColors.primaryButton
                              : AppColors.surface,
                          onTap: () {
                            if (showShops) {
                              onSelectCategories();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  final String text;

  const _EmptyFavoritesState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// popup
Future<bool?> showRemoveFavoriteDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => appDialog(
      title: title,
      content: content,
      actions: [
        CustomTextButton.small(
          label: 'Anuluj',
          width: 100,
          onTap: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: 8),
        CustomTextButton.primarySmall(
          label: 'Usuń',
          width: 100,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}