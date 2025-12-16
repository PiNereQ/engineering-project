import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


class ListedCoupon extends Equatable {
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

  final bool isSold;
  final DateTime listingDate;
  final String code;

  const ListedCoupon({
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
    required this.isSold,
    required this.listingDate,
    required this.code,
  });

  @override
  List<Object?> get props => [
    id,
    reduction,
    reductionIsPercentage,
    price,
    hasLimits,
    worksOnline,
    worksInStore,
    expiryDate,
    description,
    shopId,
    shopName,
    shopNameColor,
    shopBgColor,
    isSold,
    listingDate,
    code,
  ];
}