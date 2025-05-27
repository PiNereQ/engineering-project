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
        hasLimits: doc['hasLimits'],
        worksOnline: doc['worksOnline'],
        worksInStore: doc['worksInStore'],
        expiryDate: (doc['expiryDate'] as Timestamp).toDate(),
        shopId: shopDoc.id,
        shopName: shopDoc['name'],
        shopNameColor: Color(shopDoc['nameColor']),
        shopBgColor: Color(shopDoc['bgColor']),
        sellerId: sellerDoc.id,
        sellerReputation: sellerDoc['reputation'],
      );
    }).toList());
  }

  Future<Coupon> fetchCouponDetails(String id) async {
    final doc = await FirebaseFirestore.instance
      .collection('coupons').doc(id).get();

    final shopDoc = await FirebaseFirestore.instance
      .collection('shops')
      .doc(doc['shopId'].toString())
      .get();

    final sellerDoc = await FirebaseFirestore.instance
      .collection('userProfileData')
      .doc(doc['sellerId'].toString())
      .get();

    return Coupon(
      id: doc.id,
      reduction: doc['reduction'],
      reductionIsPercentage: doc['reductionIsPercentage'],
      price: doc['pricePLN'],
      hasLimits: doc['hasLimits'],
      worksOnline: doc['worksOnline'],
      worksInStore: doc['worksInStore'],
      expiryDate: (doc['expiryDate'] as Timestamp).toDate(),
      description: doc['description'],
      shopId: shopDoc.id,
      shopName: shopDoc['name'],
      shopNameColor: Color(shopDoc['nameColor']),
      shopBgColor: Color(shopDoc['bgColor']),
      sellerId: sellerDoc.id,
      sellerReputation: sellerDoc['reputation'],
      sellerUsername: sellerDoc['username'],
      sellerJoinDate: (sellerDoc['joinDate'] as Timestamp).toDate(),
    );
  }
}