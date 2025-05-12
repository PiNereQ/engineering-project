import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Coupon extends Equatable {
  final String id;
  final double reduction;
  final bool reductionIsPercentage;
  final double price;
  final String shopName;
  final Color shopNameColor;
  final Color shopBgColor;
  final bool hasLimits;
  final String sellerId;
  final String sellerUsername;
  final int sellerReputation;
  final bool isOnline;
  final DateTime expiryDate;

  const Coupon({
    required this.id,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,
    required this.shopName,
    required this.shopNameColor,
    required this.shopBgColor,
    required this.hasLimits,
    required this.sellerId,
    required this.sellerUsername,
    required this.sellerReputation,
    required this.isOnline,
    required this.expiryDate,
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
    isOnline,
    expiryDate,
  ];
}