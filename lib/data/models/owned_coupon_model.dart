import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OwnedCoupon extends Equatable {
  final String id;
  final double reduction;
  final bool reductionIsPercentage;
  final double price;
  
  final bool hasLimits;
  final bool worksOnline;
  final bool worksInStore;
  final DateTime expiryDate;
  final String? description;

  final String shopId;
  final String shopName;
  final Color shopNameColor; 
  final Color shopBgColor;

  final String sellerId;
  final String? sellerUsername;
  final int sellerReputation;
  final DateTime? sellerJoinDate; 
  final bool isUsed;
  final String code;

  final DateTime? purchaseDate;

  const OwnedCoupon({
    required this.id,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,

    required this.hasLimits,
    required this.worksOnline,
    required this.worksInStore,
    required this.expiryDate,
    this.description,

    required this.shopId,
    required this.shopName,
    required this.shopNameColor,
    required this.shopBgColor,

    required this.sellerId,
    this.sellerUsername,
    required this.sellerReputation,
    this.sellerJoinDate,
    required this.isUsed, 
    required this.code,
    required this.purchaseDate,
  });

  @override
  List<Object?> get props => [
    id,
    reduction,
    reductionIsPercentage,
    price,
    shopId,
    shopName,
    shopNameColor,
    shopBgColor,
    hasLimits,
    sellerId,
    sellerUsername,
    sellerReputation,
    worksOnline,
    worksInStore,
    expiryDate,
    code,
    isUsed,
    purchaseDate,
  ];

  OwnedCoupon copyWith({
    String? id,
    double? reduction,
    bool? reductionIsPercentage,
    double? price,
    bool? hasLimits,
    bool? worksOnline,
    bool? worksInStore,
    DateTime? expiryDate,
    String? description,
    String? shopId,
    String? shopName,
    Color? shopNameColor,
    Color? shopBgColor,
    String? sellerId,
    String? sellerUsername,
    int? sellerReputation,
    DateTime? sellerJoinDate,
    String? code,
    bool? isUsed,
    DateTime? purchaseDate,
  }) {
    return OwnedCoupon(
      id: id ?? this.id,
      reduction: reduction ?? this.reduction,
      reductionIsPercentage: reductionIsPercentage ?? this.reductionIsPercentage,
      price: price ?? this.price,
      hasLimits: hasLimits ?? this.hasLimits,
      worksOnline: worksOnline ?? this.worksOnline,
      worksInStore: worksInStore ?? this.worksInStore,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopNameColor: shopNameColor ?? this.shopNameColor,
      shopBgColor: shopBgColor ?? this.shopBgColor,
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerReputation: sellerReputation ?? this.sellerReputation,
      sellerJoinDate: sellerJoinDate ?? this.sellerJoinDate,
      code: code ?? this.code,
      isUsed: isUsed ?? this.isUsed,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}