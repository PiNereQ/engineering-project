import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/api/api_client.dart';

class PaginatedCouponsResult {
  final List<Coupon> ownedCoupons;
  final DocumentSnapshot? lastDocument;
  PaginatedCouponsResult({required this.ownedCoupons, this.lastDocument});
}

class PaginatedOwnedCouponsResult {
  final List<OwnedCoupon> coupons;
  final DocumentSnapshot? lastDocument;
  PaginatedOwnedCouponsResult({required this.coupons, this.lastDocument});
}

class CouponRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final ApiClient _api = ApiClient(baseUrl: 'http://49.13.155.21:8000');
  
  final _shopCache = <String, DocumentSnapshot>{};
  final _sellerCache = <String, DocumentSnapshot>{};

  // ============ API-BASED METHODS ============

  /// Fetch all coupons from API (GET /coupons)
  Future<List<Map<String, dynamic>>> fetchAllCouponsFromApi() async {
    try {
      final response = await _api.getJson('/coupons');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching coupons from API: $e');
      rethrow;
    }
  }

  /// Fetch unsold listings from API (GET /listings)
  Future<List<Map<String, dynamic>>> fetchListingsFromApi() async {
    try {
      final response = await _api.getJson('/listings');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching listings from API: $e');
      rethrow;
    }
  }

  /// Fetch single coupon by ID from API (GET /coupons/{id})
  Future<Map<String, dynamic>> fetchCouponByIdFromApi(String id) async {
    try {
      final response = await _api.getJsonById('/coupons', id);
      return response as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching coupon $id from API: $e');
      rethrow;
    }
  }

  // ============ FIREBASE-BASED METHODS (LEGACY) ============

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
        ownedCoupons: coupons,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedOwnedCouponsResult> fetchOwnedCouponsPaginated(
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

    final coupons = <OwnedCoupon>[];
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
        OwnedCoupon(
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
          code: '',
          isUsed: false, // TODO: implement usage tracking
        ),
      );
    }

    return PaginatedOwnedCouponsResult(
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
      isUsed: false, // TODO: implement usage tracking
    );
  }

  /// Create new coupon offer via API (POST /coupons)
  Future<void> postCouponOffer(CouponOffer coupon) async {
    await _api.postJson('/coupons', coupon.toJson());
  }

  Future<List<Coupon>> fetchThreeCouponsForShop(String shopId) async {
    // Query up to three unsold coupons for a given shop, ordered by creation date desc
    final querySnapshot = await _firestore
        .collection('couponOffers')
        .where('isSold', isEqualTo: false)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

    final coupons = <Coupon>[];

    for (final doc in querySnapshot.docs) {
      final sellerId = doc['sellerId'].toString();

      // Shop data caching (we already know shopId, but keep consistent with the rest of the repo)
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

    return coupons;
  }
}