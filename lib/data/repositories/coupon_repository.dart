import 'package:flutter/material.dart';

import 'package:proj_inz/data/models/coupon_model.dart';

abstract class CouponRepository {

  Future<List<Coupon>> fetchCoupons() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockCoupons;
  }

  final List<Coupon> _mockCoupons = [
    Coupon(
      id: '0',
      reduction: 50.5,
      reductionIsPercentage: false,
      price: 30,
      shopName: 'MediaMarkt',
      shopNameColor: Colors.white,
      shopBgColor: Colors.red,
      hasLimits: false,
      sellerId: '0',
      sellerReputation: 90,
      sellerUsername: 'Jan Kowalski',
      isOnline: true,
      expiryDate: DateTime(2025, 12, 31),
    ),
    Coupon(
      id: '1',
      reduction: 20,
      reductionIsPercentage: true,
      price: 50,
      shopName: 'MediaMarkt',
      shopNameColor: Colors.white,
      shopBgColor: Colors.red,
      hasLimits: true,
      sellerId: '0',
      sellerReputation: 90,
      sellerUsername: 'Coupidyn',
      isOnline: false,
      expiryDate: DateTime(2025, 11, 30),
    ),
  ];
}