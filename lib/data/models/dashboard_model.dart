import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/coupon_model.dart';

class DashboardCoupon extends Equatable {
  final int couponId;
  final String code;
  final String description;
  final int listingPrice;
  final double discount;
  final List<String> categories;
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
    required this.categories,
    required this.seller,
    required this.scores,
    required this.explanation,
    required this.shoppingChannel,
    this.expiryDate,
  });

  factory DashboardCoupon.fromJson(Map<String, dynamic> json) {
    return DashboardCoupon(
      couponId: json['couponId'] as int,
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      listingPrice: json['listingPrice'] as int? ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      seller: DashboardSeller.fromJson(json['seller'] as Map<String, dynamic>),
      scores: DashboardScores.fromJson(json['scores'] as Map<String, dynamic>),
      explanation: json['explanation'] as String? ?? '',
      shoppingChannel: ShoppingChannel.fromJson(
        json['shoppingChannel'] as Map<String, dynamic>,
      ),
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.tryParse(json['expiryDate'] as String)
              : null,
    );
  }

  /// Convert to Coupon model for use with existing coupon widgets
  Coupon toCoupon() {
    return Coupon(
      id: couponId.toString(),
      reduction: discount,
      reductionIsPercentage: true,
      price: listingPrice,
      hasLimits: description.isNotEmpty,
      worksOnline: shoppingChannel.online,
      worksInStore: shoppingChannel.inStore,
      expiryDate: expiryDate,
      description: description,
      shopId: '',
      shopName: categories.isNotEmpty ? categories.first : 'Kupon',
      shopNameColor: const Color(0xFF000000),
      shopBgColor: const Color(0xFFFFFFFF),
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
    categories,
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

class FavouriteCategory extends Equatable {
  final String id;
  final String name;
  final int count;

  const FavouriteCategory({
    required this.id,
    required this.name,
    required this.count,
  });

  factory FavouriteCategory.fromJson(Map<String, dynamic> json) {
    return FavouriteCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, count];
}

class FavouriteShop extends Equatable {
  final String id;
  final String name;
  final int count;

  const FavouriteShop({
    required this.id,
    required this.name,
    required this.count,
  });

  factory FavouriteShop.fromJson(Map<String, dynamic> json) {
    return FavouriteShop(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, count];
}

class Dashboard extends Equatable {
  final FavouriteCategory? favouriteCategory;
  final List<FavouriteCategory> allFavouriteCategories;
  final FavouriteShop? favouriteShop;
  final List<FavouriteShop> allFavouriteShops;
  final List<DashboardCoupon> topRecommendedCoupons;

  const Dashboard({
    this.favouriteCategory,
    required this.allFavouriteCategories,
    this.favouriteShop,
    required this.allFavouriteShops,
    required this.topRecommendedCoupons,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      favouriteCategory:
          json['favouriteCategory'] != null
              ? FavouriteCategory.fromJson(
                json['favouriteCategory'] as Map<String, dynamic>,
              )
              : null,
      allFavouriteCategories:
          (json['allFavouriteCategories'] as List<dynamic>?)
              ?.map(
                (e) => FavouriteCategory.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      favouriteShop:
          json['favouriteShop'] != null
              ? FavouriteShop.fromJson(
                json['favouriteShop'] as Map<String, dynamic>,
              )
              : null,
      allFavouriteShops:
          (json['allFavouriteShops'] as List<dynamic>?)
              ?.map((e) => FavouriteShop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topRecommendedCoupons:
          (json['topRecommendedCoupons'] as List<dynamic>?)
              ?.map((e) => DashboardCoupon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    favouriteCategory,
    allFavouriteCategories,
    favouriteShop,
    allFavouriteShops,
    topRecommendedCoupons,
  ];
}
