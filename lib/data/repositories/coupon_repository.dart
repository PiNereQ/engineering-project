import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proj_inz/data/models/coupon_model.dart';

class CouponRepository {
  // used for fetching coupons for displaying on the list
  // TODO: pagination
  Future<List<Coupon>> fetchCoupons() async {
    final querySnapshot = await FirebaseFirestore.instance
      .collection('coupons').get();
    print('Fetching coupons');

    return await Future.wait(querySnapshot.docs.map((doc) async {
      // TODO: shop data caching
      final shopDoc = await FirebaseFirestore.instance
        .collection('shops')
        .doc(doc['shopId'].toString())
        .get();

      // TODO: seller data caching
      final sellerDoc = await FirebaseFirestore.instance
        .collection('userProfileData')
        .doc(doc['sellerId'].toString())
        .get();
      
      return Coupon(
        id: doc.id,
        reduction: doc['reduction'],
        reductionIsPercentage: doc['reductionIsPercentage'],
        price: doc['pricePLN'],
        shopId: shopDoc.id,
        shopName: shopDoc['name'],
        shopNameColor: Color(shopDoc['nameColor']),
        shopBgColor: Color(shopDoc['bgColor']),
        hasLimits: doc['hasLimits'],
        worksOnline: doc['worksOnline'],
        worksInStore: doc['worksInStore'],
        expiryDate: (doc['expiryDate'] as Timestamp).toDate(),
        sellerId: sellerDoc.id,
        sellerReputation: sellerDoc['reputation'],
      );
    }).toList());
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
      shopId: '0',
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
      shopId: '0',
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