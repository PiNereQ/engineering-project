import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proj_inz/data/models/coupon_model.dart';

class PaginatedCouponsResult {
  final List<Coupon> coupons;
  final DocumentSnapshot? lastDocument;
  PaginatedCouponsResult({required this.coupons, this.lastDocument});
}

class CouponRepository {
  final _firestore = FirebaseFirestore.instance;

  // used for fetching coupons for displaying on the list
  Future<List<Coupon>> fetchCoupons() async {
    final query = _firestore
      .collection('coupons');
      
    debugPrint('Fetching coupons');

    final querySnapshot = await query.get();

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

  Future<PaginatedCouponsResult> fetchCouponsPaginated(
    int limit,
    DocumentSnapshot? startAfter
  ) async {
    var query = _firestore
      .collection('coupons')
      .orderBy('createdAt')
      .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();

    final coupons = await Future.wait(querySnapshot.docs.map((doc) async {
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

    return PaginatedCouponsResult(
      coupons: coupons,
      lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null
    );
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