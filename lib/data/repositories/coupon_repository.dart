import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/models/listed_coupon_model.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/api/api_client.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

class PaginatedCouponsResult {
  final List<Coupon> ownedCoupons;
  final int? lastOffset;
  PaginatedCouponsResult({required this.ownedCoupons, this.lastOffset});
}

class PaginatedOwnedCouponsResult {
  final List<OwnedCoupon> coupons;
  final int? lastOffset;
  PaginatedOwnedCouponsResult({required this.coupons, this.lastOffset});
}

class PaginatedListedCouponsResult {
  final List<ListedCoupon> coupons;
  final int? lastOffset;
  PaginatedListedCouponsResult({required this.coupons, this.lastOffset});
}

class CouponRepository {
  final ApiClient _api;
  
  final _shopCache = <String, Map<String, dynamic>>{};
  final _userCache = <String, Map<String, dynamic>>{};

  UserRepository userRepository = UserRepository();

  CouponRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  // ============ API-BASED METHODS ============

  // COUPON LIST METHODS ===========================

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

  /// Fetch all active listings with merged coupon data from API (GET /listings/all/active)
  Future<List<Map<String, dynamic>>> fetchListingsFromApi() async {
    try {
      final response = await _api.getJson('/listings/all/active');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching listings from API: $e');
      rethrow;
    }
  }

  /// Fetch coupons with pagination and filters (from active listings)
  Future<PaginatedCouponsResult> fetchCouponsPaginated({
    required int limit,
    int offset = 0,
    String? shopId,
  }) async {
    try {
      final listingsData = await fetchListingsFromApi();
      
      // Filter by shop if specified
      var filtered = shopId != null 
          ? listingsData.where((listing) => listing['shop_id']?.toString() == shopId).toList()
          : listingsData;
      
      // Apply pagination
      final start = offset;
      final end = (start + limit).clamp(0, filtered.length);
      final paginated = filtered.sublist(start, end);
      
      // Convert to Coupon objects
      final coupons = await Future.wait(
        paginated.map((data) => _mapToCouponFromListing(data))
      );
      
      return PaginatedCouponsResult(
        ownedCoupons: coupons.whereType<Coupon>().toList(),
        lastOffset: end < filtered.length ? end : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch single coupon by ID from API (GET /coupons/{id})
  Future<Map<String, dynamic>> fetchCouponByIdFromApi(String id) async {
    try {
      final response = await _api.getJson('/coupons/$id');
      return response as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching coupon $id from API: $e');
      rethrow;
    }
  }

  /// Fetch coupon details by ID
  Future<Coupon> fetchCouponDetailsById(String id) async {
    try {
      final data = await fetchCouponByIdFromApi(id);
      final coupon = await _mapToCoupon(data);
      if (coupon == null) {
        throw Exception('Could not map coupon data');
      }
      return coupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchCouponDetailsById: $e');
      rethrow;
    }
  }
  
  // OWNED COUPON LIST METHODS =====================

  /// Fetch user's owned coupons (bought coupons) from API (GET /owned-coupons?owner_id={userId})
  Future<List<Map<String, dynamic>>> fetchOwnedCouponsFromApi(String userId) async {
    try {
      final response = await _api.getJson(
        '/coupons/owned',
        queryParameters: {'owner_id': userId},
      );
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching owned coupons from API: $e');
      rethrow;
    }
  }

  /// Fetch user's owned coupons (bought coupons) with pagination
  Future<PaginatedOwnedCouponsResult> fetchOwnedCouponsPaginated(
    int limit,
    int offset,
    String userId,
  ) async {
    // TODO: move pagination to backend
    // TODO: move filtering and sorting to backend
    try {
      final ownedCouponsData = await fetchOwnedCouponsFromApi(userId);
      
      // Apply pagination
      final start = offset;
      final end = (start + limit).clamp(0, ownedCouponsData.length);
      final paginated = ownedCouponsData.sublist(start, end);
      
      // Convert to OwnedCoupon objects
      final coupons = await Future.wait(
        paginated.map((data) => _mapToOwnedCoupon(data))
      );
      
      return PaginatedOwnedCouponsResult(
        coupons: coupons.whereType<OwnedCoupon>().toList(),
        lastOffset: end < ownedCouponsData.length ? end : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch owned coupon details by ID
  Future<OwnedCoupon> fetchOwnedCouponDetailsById(String id) async {
    try {
      final userId = await userRepository.getCurrentUserId();
      final data = await _api.getJson('/coupons/owned/$id', queryParameters: {"owner_id": userId});
      final ownedCoupon = await _mapToOwnedCoupon(data);
      if (ownedCoupon == null) {
        throw Exception('Could not map coupon data');
      }
      return ownedCoupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponDetailsById: $e');
      rethrow;
    }
  }

  // LISTED COUPON LIST METHODS ====================
  
  /// Fetch user's listed coupons (GET /coupons/listed?seller_id={userId})
  Future<List<Map<String, dynamic>>> fetchListedCouponsFromApi(String userId) async {
    try {
      final response = await _api.getJson(
        '/coupons/listed',
        queryParameters: {'seller_id': userId},
      );
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching listed coupons from API: $e');
      rethrow;
    }
  }

  /// Fetch listed coupons with pagination (GET /coupons/listed)
  Future<PaginatedListedCouponsResult> fetchListedCouponsPaginated(
    int limit,
    int offset,
    String userId,
  ) async {
    // TODO: move pagination to backend
    // TODO: move filtering and sorting to backend
    try {
      final listedCouponsData = await fetchListedCouponsFromApi(userId);
      final start = offset;
      final end = (start + limit).clamp(0, listedCouponsData.length);
      final paginated = listedCouponsData.sublist(start, end);
      final coupons = await Future.wait(
        paginated.map((data) => _mapToListedCoupon(data)),
      );
      return PaginatedListedCouponsResult(
        coupons: coupons.whereType<ListedCoupon>().toList(),
        lastOffset: end < listedCouponsData.length ? end : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchListedCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch listed coupon details by ID (GET /coupons/listed/:id)
  Future<ListedCoupon> fetchListedCouponDetailsById(String id, String userId) async {
    try {
      final data = await _api.getJson(
        '/coupons/listed/$id',
        queryParameters: {'seller_id': userId},
      );
      final coupon = await _mapToListedCoupon(data);
      if (coupon == null) {
        throw Exception('Could not map listed coupon data');
      }
      return coupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchListedCouponDetailsById: $e');
      rethrow;
    }
  }

  // SOLD COUPON LIST METHODS ======================

  // /// Fetch user's sold coupons (completed transactions) from API (GET /transactions?seller_id={userId})
  // Future<List<Map<String, dynamic>>> fetchSoldCouponsFromApi(String userId) async {
  //   try {
  //     final response = await _api.getJson('/transactions?seller_id=$userId');
  //     if (response is List) {
  //       return response.cast<Map<String, dynamic>>();
  //     }
  //     return [];
  //   } catch (e) {
  //     if (kDebugMode) debugPrint('Error fetching sold coupons from API: $e');
  //     rethrow;
  //   }
  // }

  // /// Fetch user's sold coupons (completed transactions) with pagination
  // Future<PaginatedCouponsResult> fetchSoldCouponsPaginated({
  //   required int limit,
  //   required int offset,
  //   required String userId,
  // }) async {
  //   try {
  //     final transactionsData = await fetchSoldCouponsFromApi(userId);
      
  //     // Merge with coupon data
  //     List<Map<String, dynamic>> merged = [];
  //     for (var transaction in transactionsData) {
  //       final couponData = await fetchCouponByIdFromApi(transaction['coupon_id'].toString());
  //       merged.add({
  //         ...couponData,
  //         'transaction_id': transaction['id'].toString(),
  //         'transaction_price': transaction['price'],
  //         'buyer_id': transaction['buyer_id'],
  //         'transaction_date': transaction['created_at'],
  //       });
  //     }
      
  //     // Apply pagination
  //     final start = offset;
  //     final end = (start + limit).clamp(0, merged.length);
  //     final paginated = merged.sublist(start, end);
      
  //     // Convert to Coupon objects (marked as sold)
  //     final coupons = await Future.wait(
  //       paginated.map((data) => _mapToCouponFromTransaction(data))
  //     );
      
  //     return PaginatedCouponsResult(
  //       ownedCoupons: coupons.whereType<Coupon>().toList(),
  //       lastOffset: end < merged.length ? end : null,
  //     );
  //   } catch (e) {
  //     if (kDebugMode) debugPrint('Error in fetchSoldCouponsPaginated: $e');
  //     rethrow;
  //   }
  // }
  
  // GENERAL METHODS ===============================

  /// Create new coupon offer via API (POST /coupons)
  Future<void> postCouponOffer(CouponOffer coupon) async {
    try {
      await _api.postJson('/coupons', body: coupon.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('Error posting coupon: $e');
      rethrow;
    }
  }
  
  /// Deactivate listed coupon via API (DELETE /coupons/{listingId})
  Future<void> deactivateListedCoupon(String listingId) async {
    try {
      await _api.deleteJson('/coupons/$listingId');
    } catch (e) {
      if (kDebugMode) debugPrint('Error in deactivateListedCoupon: $e');
      rethrow;
    }
  }

  /// Fetch three coupons for a specific shop
  Future<List<Coupon>> fetchThreeCouponsForShop(String shopId) async {
    try {
      final result = await fetchCouponsPaginated(limit: 3, shopId: shopId);
      return result.ownedCoupons;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchThreeCouponsForShop: $e');
      rethrow;
    }
  }

  // ============ HELPER METHODS ============

  /// Map API data to Coupon model
  Future<Coupon?> _mapToCoupon(Map<String, dynamic> data) async {
    try {
      final shopId = data['shop_id'].toString();
      final sellerId = data['seller_id']?.toString();
      
      final shopData = await _getShopData(shopId);
      Map<String, dynamic>? ownerData;
      if (sellerId != null) {
        ownerData = await _getUserData(sellerId);
      }
      
      return Coupon(
        id: data['id'].toString(),
        listingId: null, // No listing ID when fetching coupon directly
        reduction: _parseNum(data['discount']),
        reductionIsPercentage: data['is_discount_percentage'] == true || data['is_discount_percentage'] == 1,
        price: _parseNum(data['price']),
        hasLimits: data['has_limits'] == true || data['has_limits'] == 1,
        worksOnline: data['works_online'] == true || data['works_online'] == 1,
        worksInStore: data['works_in_store'] == true || data['works_in_store'] == 1,
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : DateTime.now().add(Duration(days: 30)),
        description: data['description'],
        isMultipleUse: data['is_multiple_use'] == true || data['is_multiple_use'] == 1,
        shopId: shopId,
        shopName: shopData['name'] ?? 'Unknown Shop',
        shopNameColor: _parseColor(shopData['name_color']),
        shopBgColor: _parseColor(shopData['bg_color']),
        sellerId: sellerId ?? '',
        sellerReputation: ownerData?['reputation'] ?? 0,
        sellerUsername: ownerData?['username'],
        isSold: false, // TODO: implement from listings/transactions
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error mapping coupon: $e');
      return null;
    }
  }

  /// Map listing data (with merged coupon data from /listings/all/active) to Coupon model
  Future<Coupon?> _mapToCouponFromListing(Map<String, dynamic> data) async {
    try {
      final shopId = data['shop_id'].toString();
      final sellerId = data['seller_id']?.toString();
      
      final shopData = await _getShopData(shopId);
      
      if (kDebugMode) {
        debugPrint('Mapping listing: coupon_id=${data['coupon_id']}, listing_id=${data['id']}');
      }
      
      return Coupon(
        id: data['coupon_id'].toString(), // Coupon ID
        listingId: data['id'].toString(), // Listing ID (from the listings table)
        reduction: _parseNum(data['discount']),
        reductionIsPercentage: data['is_discount_percentage'] == true || data['is_discount_percentage'] == 1,
        price: _parseNum(data['price']), // Listing price
        hasLimits: data['has_limits'] == true || data['has_limits'] == 1,
        worksOnline: data['works_online'] == true || data['works_online'] == 1,
        worksInStore: data['works_in_store'] == true || data['works_in_store'] == 1,
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : DateTime.now().add(Duration(days: 365)),
        description: data['description'],
        shopId: shopId,
        shopName: shopData['name'] ?? 'Unknown Shop',
        shopNameColor: _parseColor(shopData['name_color']),
        shopBgColor: _parseColor(shopData['bg_color']),
        sellerId: sellerId ?? '',
        sellerReputation: 0, // Not included in this endpoint
        sellerUsername: data['seller_username'],
        isSold: false, // Active listings are not sold
        isMultipleUse: data['is_multiple_use'] == true || data['is_multiple_use'] == 1,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error mapping listing to coupon: $e');
      return null;
    }
  }
  
  /// Map API data to OwnedCoupon model
  Future<OwnedCoupon?> _mapToOwnedCoupon(Map<String, dynamic> data) async {
    try {
      return OwnedCoupon(
        id: data['id'].toString(),
        reduction: _parseNum(data['discount']),
        reductionIsPercentage: data['is_discount_percentage'] == true || data['is_discount_percentage'] == 1,
        price: _parseNum(data['price']),
        hasLimits: data['has_limits'] == true || data['has_limits'] == 1,
        worksOnline: data['works_online'] == true || data['works_online'] == 1,
        worksInStore: data['works_in_store'] == true || data['works_in_store'] == 1,
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : DateTime.now().add(Duration(days: 30)),
        description: data['description'],
        shopId: data['shop_id'].toString(),
        shopName: data['shop_name'] ?? 'Unknown Shop',
        shopNameColor: _parseColor(data['shop_name_color']),
        shopBgColor: _parseColor(data['shop_bg_color']),
        sellerId: data['seller_id'].toString(),
        sellerReputation: data['seller_reputation'] ?? 0,
        sellerUsername: data['seller_username'],
        sellerJoinDate: data['seller_join_date'] != null ? DateTime.parse(data['seller_join_date']) : DateTime.fromMillisecondsSinceEpoch(0),
        code: data['code'] ?? '',
        isUsed: false,
        purchaseDate: data['purchase_date'] != null ? DateTime.parse(data['purchase_date']) : DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error mapping owned coupon: $e');
      return null;
    }
  }

  /// Map API data to ListedCoupon model
  Future<ListedCoupon?> _mapToListedCoupon(Map<String, dynamic> data) async {
    try {
      final shopId = data['shop_id'].toString();
      final shopData = await _getShopData(shopId);
      return ListedCoupon(
        id: data['id'].toString(),
        listingId: data['listing_id'].toString(),
        reduction: _parseNum(data['discount']),
        reductionIsPercentage: data['is_discount_percentage'] == true || data['is_discount_percentage'] == 1,
        price: _parseNum(data['price']),
        hasLimits: data['has_limits'] == true || data['has_limits'] == 1,
        worksOnline: data['works_online'] == true || data['works_online'] == 1,
        worksInStore: data['works_in_store'] == true || data['works_in_store'] == 1,
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : DateTime.now().add(Duration(days: 30)),
        description: data['description'],
        shopId: shopId,
        shopName: shopData['name'] ?? 'Unknown Shop',
        shopNameColor: _parseColor(shopData['name_color']),
        shopBgColor: _parseColor(shopData['bg_color']),
        isSold: data['is_sold'] == true || data['is_sold'] == 1,
        listingDate: data['listing_date'] != null ? DateTime.parse(data['listing_date']) : DateTime.fromMillisecondsSinceEpoch(0),
        code: data['code'] ?? '',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error mapping listed coupon: $e');
      return null;
    }
  }

  /// Get shop data with caching
  Future<Map<String, dynamic>> _getShopData(String shopId) async {
    if (_shopCache.containsKey(shopId)) {
      return _shopCache[shopId]!;
    }
    
    try {
      final data = await _api.getJson('/shops/$shopId');
      _shopCache[shopId] = data as Map<String, dynamic>;
      return _shopCache[shopId]!;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching shop $shopId: $e');
      return {'name': 'Unknown Shop', 'name_color': '#000000', 'bg_color': '#FFFFFF'};
    }
  }

  /// Get user data with caching
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }
    
    try {
      final data = await _api.getJson('/users/$userId');
      _userCache[userId] = data as Map<String, dynamic>;
      return _userCache[userId]!;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching user $userId: $e');
      return {'username': 'Unknown User', 'reputation': 0};
    }
  }

  /// Parse color from hex string
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.black;
    
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing color $hexColor: $e');
      return Colors.black;
    }
  }

  /// Parse number from dynamic type (handles both num and String)
  double _parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}