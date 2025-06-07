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
  
  final shopCache = <String, DocumentSnapshot>{};
  final sellerCache = <String, DocumentSnapshot>{};

  Future<PaginatedCouponsResult> fetchCouponsPaginated(
    int limit,
    DocumentSnapshot? startAfter
  ) async {

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'User is not authenticated.',
      );
    }

    var query = _firestore
      .collection('couponOffers')
      .where('isSold', isEqualTo: false)
      .orderBy('createdAt')
      .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();

    final coupons = <Coupon>[];
    for (final doc in querySnapshot.docs) {
      final shopId = doc['shopId'].toString();
      final sellerId = doc['sellerId'].toString();

      // Shop data caching
      DocumentSnapshot shopDoc;
      if (shopCache.containsKey(shopId)) {
        shopDoc = shopCache[shopId]!;
      } else {
        shopDoc = await _firestore.collection('shops').doc(shopId).get();
        shopCache[shopId] = shopDoc;
      }

      // Seller data caching
      DocumentSnapshot sellerDoc;
      if (sellerCache.containsKey(sellerId)) {
        sellerDoc = sellerCache[sellerId]!;
      } else {
        sellerDoc = await _firestore.collection('userProfileData').doc(sellerId).get();
        sellerCache[sellerId] = sellerDoc;
      }

      coupons.add(Coupon(
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
      ));
    }

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

    // Shop data caching
    DocumentSnapshot shopDoc;
    if (shopCache.containsKey(id)) {
      shopDoc = shopCache[id]!;
    } else {
      shopDoc = await _firestore.collection('shops').doc(id).get();
      shopCache[id] = shopDoc;
    }

    // Seller data caching
      DocumentSnapshot sellerDoc;
    if (sellerCache.containsKey(id)) {
      sellerDoc = sellerCache[id]!;
    } else {
      sellerDoc = await _firestore.collection('userProfileData').doc(id).get();
      sellerCache[id] = sellerDoc;
    }

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