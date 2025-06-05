import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';

class PaginatedCouponsResult {
  final List<Coupon> coupons;
  final DocumentSnapshot? lastDocument;
  PaginatedCouponsResult({required this.coupons, this.lastDocument});
}

class CouponRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<PaginatedCouponsResult> fetchCouponsPaginated(
    int limit,
    DocumentSnapshot? startAfter
  ) async {
    var query = _firestore
      .collection('couponOffers')
      .where('isSold', isEqualTo: false)
      .orderBy('createdAt')
      .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();

    final coupons = await Future.wait(querySnapshot.docs.map((doc) async {
      // TODO: shop data caching
      final shopDoc = await _firestore
        .collection('shops')
        .doc(doc['shopId'].toString())
        .get();

      // TODO: seller data caching
      final sellerDoc = await _firestore
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
        isSold: doc['isSold'],
      );
    }).toList());

    return PaginatedCouponsResult(
      coupons: coupons,
      lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null
    );
  }

  Future<Coupon> fetchCouponDetailsById(String id) async {
    final doc = await _firestore
      .collection('couponOffers')
      .doc(id)
      .get();

    final shopDoc = await _firestore
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
      isSold: doc['isSold'],
    );
  }

  
  Future<void> postCouponOffer(CouponOffer coupon) async { 
    // TODO: add posting coupon codes to Firestore 
    // (perhaps move to Cloud Functions?)
    await _firestore.collection('couponOffers').add({
      'reduction': coupon.reduction,
      'reductionIsPercentage': coupon.reductionIsPercentage,
      'pricePLN': coupon.price,
      'hasLimits': coupon.hasLimits,
      'worksOnline': coupon.worksOnline,
      'worksInStore': coupon.worksInStore,
      'expiryDate': coupon.expiryDate,
      'description': coupon.description,
      'shopId': coupon.shopId,
      'sellerId': _firebaseAuth.currentUser?.uid,
      'isSold': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}