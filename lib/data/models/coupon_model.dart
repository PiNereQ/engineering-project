import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Coupon extends Equatable {
  final String id;
  final double reduction;
  final bool reductionIsPercentage;
  final double price;
  final bool hasLimits;
  final bool worksOnline;
  final bool worksInStore;
  final DateTime expiryDate;

  final String shopName;
  final Color shopNameColor; 
  final Color shopBgColor;
  
  final String? description;

  final String sellerId;
  final String? sellerUsername;
  final int sellerReputation;
  final DateTime? sellerJoinDate; 

  const Coupon({
    required this.id,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,
    required this.shopName,
    required this.shopNameColor,
    required this.shopBgColor,
    required this.hasLimits,
    
    required this.worksOnline,
    required this.worksInStore,
    required this.expiryDate,
    this.description,

    required this.sellerId,
    this.sellerUsername,
    required this.sellerReputation,
    this.sellerJoinDate,
  });

  @override
  List<Object?> get props => [
    id,
    reduction,
    reductionIsPercentage,
    price,
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
  ];

  Coupon copyWith({
    String? id,
    double? reduction,
    bool? reductionIsPercentage,
    double? price,
    String? shopName,
    Color? shopNameColor,
    Color? shopBgColor,
    bool? hasLimits,
    bool? worksOnline,
    bool? worksInStore,
    DateTime? expiryDate,
    String? description,
    String? sellerId,
    String? sellerUsername,
    int? sellerReputation,
    DateTime? sellerJoinDate,
  }) {
    return Coupon(
      id: id ?? this.id,
      reduction: reduction ?? this.reduction,
      reductionIsPercentage: reductionIsPercentage ?? this.reductionIsPercentage,
      price: price ?? this.price,
      shopName: shopName ?? this.shopName,
      shopNameColor: shopNameColor ?? this.shopNameColor,
      shopBgColor: shopBgColor ?? this.shopBgColor,
      hasLimits: hasLimits ?? this.hasLimits,
      worksOnline: worksOnline ?? this.worksOnline,
      worksInStore: worksInStore ?? this.worksInStore,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerReputation: sellerReputation ?? this.sellerReputation,
      sellerJoinDate: sellerJoinDate ?? this.sellerJoinDate,
    );
  }
}