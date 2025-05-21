import 'package:flutter/material.dart';

import 'package:proj_inz/data/models/coupon_model.dart';

class CouponRepository {

  // used for fetching coupons for displaying on the list
  Future<List<Coupon>> fetchCoupons() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockCoupons.map((c) => c.copyWith(
      description: null,
      sellerUsername: null,
      sellerJoinDate: null
    )).toList();
  }

  Future<Coupon> fetchCouponDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockCoupons.firstWhere((coupon) => coupon.id == id);
  }

  final List<Coupon> _mockCoupons = [
    Coupon(
      id: '0',
      reduction: 50.5,
      reductionIsPercentage: false,
      price: 30,
      hasLimits: false,
      worksOnline: true,
      worksInStore: true,
      expiryDate: DateTime(2025, 12, 31),
      shopName: 'MediaMarkt',
      shopNameColor: Colors.white,
      shopBgColor: const Color(0xFFDF0000),
      description: 'Lorem ipsum dolor sit amet',
      sellerId: '0',
      sellerReputation: 90,
      sellerUsername: 'Jan Kowalski',
      sellerJoinDate: DateTime(2024, 12, 31)
    ),
    Coupon(
      id: '1',
      reduction: 20,
      reductionIsPercentage: true,
      price: 50,
      hasLimits: true,
      worksOnline: false,
      worksInStore: true,
      expiryDate: DateTime(2025, 11, 30),
      shopName: 'MediaMarkt',
      shopNameColor: Colors.white,
      shopBgColor: const Color(0xFFDF0000),
      description: 'Lorem ipsum dolor sit amet',
      sellerId: '0',
      sellerReputation: 90,
      sellerUsername: 'Coupidyn',
      sellerJoinDate: DateTime(2025, 01, 01)
    ),
  ];
}