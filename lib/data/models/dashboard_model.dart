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

/// Recommended coupon from the recommendation engine
class DashboardCoupon extends Equatable {
  final int couponId;
  final String code;
  final String description;
  final int listingPrice;
  final double discount;
  final bool isDiscountPercentage;
  final List<String> categories;
  final DashboardShop shop;
  final DashboardSeller seller;
  final DashboardScores scores;
  final String explanation;
  final ShoppingChannel shoppingChannel;
  final DateTime? expiryDate;

  const DashboardCoupon({
    required this.couponId,
    required this.code,
    required this.description,
    required this.listingPrice,
    required this.discount,
    required this.isDiscountPercentage,
    required this.categories,
    required this.shop,
    required this.seller,
    required this.scores,
    required this.explanation,
    required this.shoppingChannel,
    this.expiryDate,
  });

  factory DashboardCoupon.fromJson(Map<String, dynamic> json) {
    final shopJson = json['shop'] as Map<String, dynamic>?;
    
    return DashboardCoupon(
      couponId: json['couponId'] as int,
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      listingPrice: json['listingPrice'] as int? ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      isDiscountPercentage: json['is_discount_percentage'] == 1 || json['is_discount_percentage'] == true,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      shop: shopJson != null
          ? DashboardShop.fromJson(shopJson)
          : const DashboardShop(
              id: '',
              name: 'Kupon',
              nameColor: Color(0xFF000000),
              bgColor: Color(0xFFFFFFFF),
            ),
      seller: DashboardSeller.fromJson(json['seller'] as Map<String, dynamic>),
      scores: DashboardScores.fromJson(json['scores'] as Map<String, dynamic>),
      explanation: json['explanation'] as String? ?? '',
      shoppingChannel: ShoppingChannel.fromJson(
        json['shoppingChannel'] as Map<String, dynamic>,
      ),
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
    );
  }

  /// Convert to Coupon model for use with existing coupon widgets
  Coupon toCoupon() {
    return Coupon(
      id: couponId.toString(),
      reduction: discount,
      reductionIsPercentage: isDiscountPercentage,
      price: listingPrice,
      hasLimits: description.isNotEmpty,
      worksOnline: shoppingChannel.online,
      worksInStore: shoppingChannel.inStore,
      expiryDate: expiryDate,
      description: description,
      shopId: shop.id,
      shopName: shop.name,
      shopNameColor: shop.nameColor,
      shopBgColor: shop.bgColor,
      listingDate: DateTime.now(),
      isSold: false,
      sellerId: seller.id,
      sellerUsername: seller.username,
      sellerReputation: seller.reputation,
      code: code,
    );
  }

  @override
  List<Object?> get props => [
        couponId,
        code,
        description,
        listingPrice,
        discount,
        isDiscountPercentage,
        categories,
        shop,
        seller,
        scores,
        explanation,
        shoppingChannel,
        expiryDate,
      ];
}

class DashboardSeller extends Equatable {
  final String id;
  final String username;
  final int reputation;
  final int ratingCount;

  const DashboardSeller({
    required this.id,
    required this.username,
    required this.reputation,
    required this.ratingCount,
  });

  factory DashboardSeller.fromJson(Map<String, dynamic> json) {
    return DashboardSeller(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      reputation: json['reputation'] as int? ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, username, reputation, ratingCount];
}

class DashboardScores extends Equatable {
  final double contentBased;
  final double collaborative;
  final double sellerReputation;
  final double popularity;
  final double finalScore;

  const DashboardScores({
    required this.contentBased,
    required this.collaborative,
    required this.sellerReputation,
    required this.popularity,
    required this.finalScore,
  });

  factory DashboardScores.fromJson(Map<String, dynamic> json) {
    return DashboardScores(
      contentBased: (json['contentBased'] as num?)?.toDouble() ?? 0.0,
      collaborative: (json['collaborative'] as num?)?.toDouble() ?? 0.0,
      sellerReputation: (json['sellerReputation'] as num?)?.toDouble() ?? 0.0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      finalScore: (json['final'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        contentBased,
        collaborative,
        sellerReputation,
        popularity,
        finalScore,
      ];
}

class ShoppingChannel extends Equatable {
  final bool online;
  final bool inStore;

  const ShoppingChannel({required this.online, required this.inStore});

  factory ShoppingChannel.fromJson(Map<String, dynamic> json) {
    return ShoppingChannel(
      online: json['online'] as bool? ?? false,
      inStore: json['inStore'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [online, inStore];
}

/// Main dashboard model
class Dashboard extends Equatable {
  final FavouriteCategorySection? favouriteCategory;
  final List<Coupon> allFavouriteCategoriesCoupons;
  final FavouriteShopSection? favouriteShop;
  final List<Coupon> allFavouriteShopsCoupons;
  final List<DashboardCoupon> topRecommendedCoupons;

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
              ?.map((e) => DashboardCoupon.fromJson(e as Map<String, dynamic>))
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
