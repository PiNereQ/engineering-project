import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';

class PaginatedCouponsResult {
  final List<Coupon> coupons;
  final DocumentSnapshot? lastDocument;
  PaginatedCouponsResult({required this.coupons, this.lastDocument});
}

class PaginatedOwnedCouponsResult {
  final List<OwnedCoupon> coupons;
  final DocumentSnapshot? lastDocument;
  PaginatedOwnedCouponsResult({required this.coupons, this.lastDocument});
}

class CouponRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  final _shopCache = <String, DocumentSnapshot>{};
  final _sellerCache = <String, DocumentSnapshot>{};

  Future<PaginatedCouponsResult> fetchCouponsPaginated(
    {required int limit,
    required DocumentSnapshot? startAfter,
    bool? reductionIsPercentage,
    bool? reductionIsFixed,
    double? minPrice,
    double? maxPrice,
    num? minReputation,
    required Ordering ordering,
    String? shopId}
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
      .where('isSold', isEqualTo: false);
      
    if (shopId != null) {
      query = query.where('shopId', isEqualTo: shopId);
    }
    else if (reductionIsPercentage == true && reductionIsFixed == false) {
      // 'rabat %' is chosen, but not 'rabat zł'
      query = query.where('reductionIsPercentage', isEqualTo: true);
    } else if (reductionIsFixed == true && reductionIsPercentage == false) {
      // 'rabat zł' is chosen, but not 'rabat %'
      query = query.where('reductionIsPercentage', isEqualTo: false);
    } else if (reductionIsFixed == false && reductionIsPercentage == false) {
      // none are chosen -> no coupons
      query = query.where('reductionIsPercentage', isEqualTo: true);
      query = query.where('reductionIsPercentage', isEqualTo: false);
    }

    if (minPrice != null) {
      query = query.where('pricePLN', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('pricePLN', isLessThanOrEqualTo: maxPrice);
    }

    // TODO: filtering for reputation using _minReputation - might require denormalisation on Firestore

    switch (ordering) {
      case Ordering.creationDateAsc:
        query = query.orderBy('createdAt').limit(limit);
        break;
      case Ordering.creationDateDesc:
        query = query.orderBy('createdAt', descending: true).limit(limit);
        break;
      case Ordering.expiryDateAsc:
        query = query.orderBy('expiryDate').limit(limit);
        break;
      case Ordering.expiryDateDesc:
        query = query.orderBy('expiryDate', descending: true).limit(limit);
        break;
      case Ordering.priceAsc:
        query = query.orderBy('pricePLN').limit(limit);
        break;
      case Ordering.priceDesc:
        query = query.orderBy('pricePLN', descending: true).limit(limit);
        break;
      // TODO: sorting by reputation - might require denormalisation on Firestore
      default:
        query = query.orderBy('createdAt', descending: true).limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    try {
      final querySnapshot = await query.get();
    

      final coupons = <Coupon>[];
      for (final doc in querySnapshot.docs) {
        final shopId = doc['shopId'].toString();
        final sellerId = doc['sellerId'].toString();

        // Shop data caching
        DocumentSnapshot shopDoc;
        if (_shopCache.containsKey(shopId)) {
          shopDoc = _shopCache[shopId]!;
        } else {
          shopDoc = await _firestore.collection('shops').doc(shopId).get();
          _shopCache[shopId] = shopDoc;
        }

        // Seller data caching
        DocumentSnapshot sellerDoc;
        if (_sellerCache.containsKey(sellerId)) {
          sellerDoc = _sellerCache[sellerId]!;
        } else {
          sellerDoc = await _firestore.collection('userProfileData').doc(sellerId).get();
          _sellerCache[sellerId] = sellerDoc;
        }

        try {
          coupons.add(Coupon(
            id: doc.id,
            reduction: doc['reduction'].toDouble(),
            reductionIsPercentage: doc['reductionIsPercentage'],
            price: doc['pricePLN'].toDouble(),
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
        } catch (e) {
          if (kDebugMode) debugPrint('Error while getting coupon with id ${doc.id}: $e');
        }
      }

      return PaginatedCouponsResult(
        coupons: coupons,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedCouponsResult> fetchOwnedCouponsPaginated(
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

    var ownershipQuery = _firestore
      .collection('couponCodeData')
      .where('owner', isEqualTo: user.uid)
      .limit(limit);

    if (startAfter != null) {
      ownershipQuery = ownershipQuery.startAfterDocument(startAfter);
    }
    
    final ownershipQuerySnapshot = await ownershipQuery.get();
    print(ownershipQuerySnapshot.docs.length);

    final coupons = <Coupon>[];
    for (final codeDataDoc in ownershipQuerySnapshot.docs) {
      final couponDoc = await _firestore
        .collection('couponOffers')
        .doc(codeDataDoc.id)
        .get();

      final shopId = couponDoc['shopId'].toString();
      final sellerId = couponDoc['sellerId'].toString();

      // Shop data caching
      DocumentSnapshot shopDoc;
      if (_shopCache.containsKey(shopId)) {
        shopDoc = _shopCache[shopId]!;
      } else {
        shopDoc = await _firestore.collection('shops').doc(shopId).get();
        _shopCache[shopId] = shopDoc;
      }

      // Seller data caching
      DocumentSnapshot sellerDoc;
      if (_sellerCache.containsKey(sellerId)) {
        sellerDoc = _sellerCache[sellerId]!;
      } else {
        sellerDoc = await _firestore.collection('userProfileData').doc(sellerId).get();
        _sellerCache[sellerId] = sellerDoc;
      }

      coupons.add(
        Coupon(
          id: codeDataDoc.id,
          reduction: couponDoc['reduction'],
          reductionIsPercentage: couponDoc['reductionIsPercentage'],
          price: couponDoc['pricePLN'],
          hasLimits: couponDoc['hasLimits'],
          worksOnline: couponDoc['worksOnline'],
          worksInStore: couponDoc['worksInStore'],
          expiryDate: (couponDoc['expiryDate'] as Timestamp).toDate(),
          shopId: shopDoc.id,
          shopName: shopDoc['name'],
          shopNameColor: Color(shopDoc['nameColor']),
          shopBgColor: Color(shopDoc['bgColor']),
          sellerId: sellerDoc.id,
          sellerReputation: sellerDoc['reputation'],
          isSold: true
        ),
      );
    }

    return PaginatedCouponsResult(
      coupons: coupons,
      lastDocument: ownershipQuerySnapshot.docs.isNotEmpty ? ownershipQuerySnapshot.docs.last : null
    );
  }

  Future<Coupon> fetchCouponDetailsById(String id) async {
    final doc = await _firestore
      .collection('couponOffers')
      .doc(id)
      .get();

    final shopId = doc['shopId'].toString();
    final sellerId = doc['sellerId'].toString();

    // Shop data caching
    DocumentSnapshot shopDoc;
    if (_shopCache.containsKey(shopId)) {
      shopDoc = _shopCache[shopId]!;
    } else {
      shopDoc = await _firestore.collection('shops').doc(shopId).get();
      _shopCache[shopId] = shopDoc;
    }

    // Seller data caching
    DocumentSnapshot sellerDoc;
    if (_sellerCache.containsKey(sellerId)) {
      sellerDoc = _sellerCache[sellerId]!;
    } else {
      sellerDoc = await _firestore.collection('userProfileData').doc(sellerId).get();
      _sellerCache[sellerId] = sellerDoc;
    }

    return Coupon(
      id: doc.id,
      reduction: doc['reduction'].toDouble(),
      reductionIsPercentage: doc['reductionIsPercentage'],
      price: doc['pricePLN'].toDouble(),
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

  Future<OwnedCoupon> fetchOwnedCouponDetailsById(String id) async {
    final publicDataDoc = await _firestore
      .collection('couponOffers')
      .doc(id)
      .get();
    
    final shopId = publicDataDoc['shopId'].toString();
    final sellerId = publicDataDoc['sellerId'].toString();

    // Shop data caching
    DocumentSnapshot shopDoc;
    if (_shopCache.containsKey(shopId)) {
      shopDoc = _shopCache[shopId]!;
    } else {
      shopDoc = await _firestore.collection('shops').doc(shopId).get();
      _shopCache[shopId] = shopDoc;
    }

    DocumentSnapshot sellerDoc;
    if (_sellerCache.containsKey(sellerId)) {
      sellerDoc = _sellerCache[sellerId]!;
    } else {
      sellerDoc = await _firestore.collection('userProfileData').doc(sellerId).get();
      _sellerCache[sellerId] = sellerDoc;
    }

    final privateDataDoc = await _firestore
      .collection('couponCodeData')
      .doc(id)
      .get();

    return OwnedCoupon(
      id: publicDataDoc.id,
      reduction: publicDataDoc['reduction'],
      reductionIsPercentage: publicDataDoc['reductionIsPercentage'],
      price: publicDataDoc['pricePLN'],
      hasLimits: publicDataDoc['hasLimits'],
      worksOnline: publicDataDoc['worksOnline'],
      worksInStore: publicDataDoc['worksInStore'],
      expiryDate: (publicDataDoc['expiryDate'] as Timestamp).toDate(),
      description: publicDataDoc['description'],
      shopId: shopDoc.id,
      shopName: shopDoc['name'],
      shopNameColor: Color(shopDoc['nameColor']),
      shopBgColor: Color(shopDoc['bgColor']),
      sellerId: sellerDoc.id,
      sellerReputation: sellerDoc['reputation'],
      sellerUsername: sellerDoc['username'],
      sellerJoinDate: (sellerDoc['joinDate'] as Timestamp).toDate(),
      code: privateDataDoc['code'],
    );
  }

  Future<void> postCouponOffer(CouponOffer coupon) async { 
    final docRef = await _firestore.collection('couponOffers').add({
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

    await _firestore.collection('couponCodeData').doc(docRef.id).set({
      'code': coupon.code,      
      'owner': null,
      'boughtAt': null,
    });



  }


   Future<void> buyCoupon({
    required String couponId,
    required String buyerId,
  }) async {
    await _firestore.collection('couponOffers').doc(couponId).update({
      'isSold': true,
    });

    await _firestore.collection('couponCodeData').doc(couponId).update({
      'owner': buyerId,
      'boughtAt': FieldValue.serverTimestamp(),
    });
  }
}