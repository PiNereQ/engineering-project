import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/api/api_client.dart';

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

class CouponRepository {
  final ApiClient _api;
  
  final _shopCache = <String, Map<String, dynamic>>{};
  final _userCache = <String, Map<String, dynamic>>{};

  CouponRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

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

  /// Create new coupon offer via API (POST /coupons)
  Future<void> postCouponOffer(CouponOffer coupon) async {
    try {
      await _api.postJson('/coupons', coupon.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('Error posting coupon: $e');
      rethrow;
    }
  }

  /// Fetch coupons with pagination and filters
  Future<PaginatedCouponsResult> fetchCouponsPaginated({
    required int limit,
    int offset = 0,
    String? shopId,
  }) async {
    try {
      final couponsData = await fetchAllCouponsFromApi();
      
      // Filter by shop if specified
      var filtered = shopId != null 
          ? couponsData.where((c) => c['shop_id'].toString() == shopId).toList()
          : couponsData;
      
      // Apply pagination
      final start = offset;
      final end = (start + limit).clamp(0, filtered.length);
      final paginated = filtered.sublist(start, end);
      
      // Convert to Coupon objects
      final coupons = await Future.wait(
        paginated.map((data) => _mapToCoupon(data))
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

  /// Fetch user's owned coupons
  Future<PaginatedOwnedCouponsResult> fetchOwnedCouponsPaginated(
    int limit,
    int offset,
    String userId,
  ) async {
    try {
      final couponsData = await fetchAllCouponsFromApi();
      
      // Filter by owner
      final owned = couponsData.where((c) => c['owner_id'] == userId).toList();
      
      // Apply pagination
      final start = offset;
      final end = (start + limit).clamp(0, owned.length);
      final paginated = owned.sublist(start, end);
      
      // Convert to OwnedCoupon objects
      final coupons = await Future.wait(
        paginated.map((data) => _mapToOwnedCoupon(data))
      );
      
      return PaginatedOwnedCouponsResult(
        coupons: coupons.whereType<OwnedCoupon>().toList(),
        lastOffset: end < owned.length ? end : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponsPaginated: $e');
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

  /// Fetch owned coupon details by ID
  Future<OwnedCoupon> fetchOwnedCouponDetailsById(String id) async {
    try {
      final data = await fetchCouponByIdFromApi(id);
      final ownedCoupon = await _mapToOwnedCoupon(data);
      if (ownedCoupon == null) {
        throw Exception('Could not map owned coupon data');
      }
      return ownedCoupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponDetailsById: $e');
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
      final ownerId = data['owner_id']?.toString();
      
      final shopData = await _getShopData(shopId);
      Map<String, dynamic>? ownerData;
      if (ownerId != null) {
        ownerData = await _getUserData(ownerId);
      }
      
      return Coupon(
        id: data['id'].toString(),
        reduction: (data['discount'] as num).toDouble(),
        reductionIsPercentage: data['is_discount_percentage'] == true || data['is_discount_percentage'] == 1,
        price: (data['price'] as num).toDouble(),
        hasLimits: data['has_limits'] == true || data['has_limits'] == 1,
        worksOnline: data['works_online'] == true || data['works_online'] == 1,
        worksInStore: data['works_in_store'] == true || data['works_in_store'] == 1,
        expiryDate: data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : DateTime.now().add(Duration(days: 30)),
        description: data['description'],
        shopId: shopId,
        shopName: shopData['name'] ?? 'Unknown Shop',
        shopNameColor: _parseColor(shopData['name_color']),
        shopBgColor: _parseColor(shopData['bg_color']),
        sellerId: ownerId ?? '',
        sellerReputation: ownerData?['reputation'] ?? 0,
        sellerUsername: ownerData?['username'],
        isSold: false, // TODO: implement from listings/transactions
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error mapping coupon: $e');
      return null;
    }
  }

  /// Map API data to OwnedCoupon model
  Future<OwnedCoupon?> _mapToOwnedCoupon(Map<String, dynamic> data) async {
    try {
      final coupon = await _mapToCoupon(data);
      if (coupon == null) return null;
      
      return OwnedCoupon(
        id: coupon.id,
        reduction: coupon.reduction,
        reductionIsPercentage: coupon.reductionIsPercentage,
        price: coupon.price,
        hasLimits: coupon.hasLimits,
        worksOnline: coupon.worksOnline,
        worksInStore: coupon.worksInStore,
        expiryDate: coupon.expiryDate,
        description: coupon.description,
        shopId: coupon.shopId,
        shopName: coupon.shopName,
        shopNameColor: coupon.shopNameColor,
        shopBgColor: coupon.shopBgColor,
        sellerId: coupon.sellerId,
        sellerReputation: coupon.sellerReputation,
        sellerUsername: coupon.sellerUsername,
        code: data['code'] ?? '',
        isUsed: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error mapping owned coupon: $e');
      return null;
    }
  }

  /// Get shop data with caching
  Future<Map<String, dynamic>> _getShopData(String shopId) async {
    if (_shopCache.containsKey(shopId)) {
      return _shopCache[shopId]!;
    }
    
    try {
      final data = await _api.getJsonById('/shops', shopId);
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
      final data = await _api.getJsonById('/users', userId);
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
}