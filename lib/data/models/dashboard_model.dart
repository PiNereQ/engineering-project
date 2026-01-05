import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';

/// Category info for dashboard
class DashboardCategory extends Equatable {
  final String id;
  final String name;
  final Color nameColor;
  final Color bgColor;

  const DashboardCategory({
    required this.id,
    required this.name,
    required this.nameColor,
    required this.bgColor,
  });

  factory DashboardCategory.fromJson(Map<String, dynamic> json) {
    return DashboardCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      nameColor: parseColor(json['name_color']?.toString()),
      bgColor: parseColor(json['bg_color']?.toString()),
    );
  }

  @override
  List<Object?> get props => [id, name, nameColor, bgColor];
}

/// Shop info for dashboard
class DashboardShop extends Equatable {
  final String id;
  final String name;
  final Color nameColor;
  final Color bgColor;

  const DashboardShop({
    required this.id,
    required this.name,
    required this.nameColor,
    required this.bgColor,
  });

  factory DashboardShop.fromJson(Map<String, dynamic> json) {
    return DashboardShop(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      nameColor: parseColor(json['name_color']?.toString()),
      bgColor: parseColor(json['bg_color']?.toString()),
    );
  }

  @override
  List<Object?> get props => [id, name, nameColor, bgColor];
}

/// Favourite category section with category info and coupons
class FavouriteCategorySection extends Equatable {
  final DashboardCategory category;
  final List<Coupon> coupons;

  const FavouriteCategorySection({
    required this.category,
    required this.coupons,
  });

  factory FavouriteCategorySection.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final couponsJson = json['coupons'] as List<dynamic>? ?? [];

    return FavouriteCategorySection(
      category: categoryJson != null
          ? DashboardCategory.fromJson(categoryJson)
          : const DashboardCategory(
              id: '',
              name: '',
              nameColor: Color(0xFF000000),
              bgColor: Color(0xFFFFFFFF),
            ),
      coupons: couponsJson
          .map((e) => Coupon.availableToMeFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [category, coupons];
}

/// Favourite shop section with shop info and coupons
class FavouriteShopSection extends Equatable {
  final DashboardShop shop;
  final List<Coupon> coupons;

  const FavouriteShopSection({
    required this.shop,
    required this.coupons,
  });

  factory FavouriteShopSection.fromJson(Map<String, dynamic> json) {
    final shopJson = json['shop'] as Map<String, dynamic>?;
    final couponsJson = json['coupons'] as List<dynamic>? ?? [];

    return FavouriteShopSection(
      shop: shopJson != null
          ? DashboardShop.fromJson(shopJson)
          : const DashboardShop(
              id: '',
              name: '',
              nameColor: Color(0xFF000000),
              bgColor: Color(0xFFFFFFFF),
            ),
      coupons: couponsJson
          .map((e) => Coupon.availableToMeFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [shop, coupons];
}

/// Main dashboard model
class Dashboard extends Equatable {
  final FavouriteCategorySection? favouriteCategory;
  final List<Coupon> allFavouriteCategoriesCoupons;
  final FavouriteShopSection? favouriteShop;
  final List<Coupon> allFavouriteShopsCoupons;
  final List<Coupon> topRecommendedCoupons;

  const Dashboard({
    this.favouriteCategory,
    required this.allFavouriteCategoriesCoupons,
    this.favouriteShop,
    required this.allFavouriteShopsCoupons,
    required this.topRecommendedCoupons,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      favouriteCategory: json['favouriteCategory'] != null
          ? FavouriteCategorySection.fromJson(
              json['favouriteCategory'] as Map<String, dynamic>,
            )
          : null,
      allFavouriteCategoriesCoupons:
          (json['allFavouriteCategories'] as List<dynamic>?)
                  ?.map((e) =>
                      Coupon.availableToMeFromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
      favouriteShop: json['favouriteShop'] != null
          ? FavouriteShopSection.fromJson(
              json['favouriteShop'] as Map<String, dynamic>,
            )
          : null,
      allFavouriteShopsCoupons: (json['allFavouriteShops'] as List<dynamic>?)
              ?.map(
                  (e) => Coupon.availableToMeFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topRecommendedCoupons: (json['topRecommendedCoupons'] as List<dynamic>?)
              ?.map((e) => Coupon.availableToMeFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        favouriteCategory,
        allFavouriteCategoriesCoupons,
        favouriteShop,
        allFavouriteShopsCoupons,
        topRecommendedCoupons,
      ];
}
