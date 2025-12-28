import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/api/api_client.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

class PaginatedCouponsResult {
  final List<Coupon> ownedCoupons;
  final Map<String, dynamic>? cursor;
  final int? lastOffset;
  PaginatedCouponsResult({required this.ownedCoupons, this.cursor, this.lastOffset});
}

class PaginatedOwnedCouponsResult {
  final List<Coupon> coupons;
  final Map<String, dynamic>? cursor;
  PaginatedOwnedCouponsResult({required this.coupons, this.cursor});
}

class PaginatedListedCouponsResult {
  final List<Coupon> coupons;
  final Map<String, dynamic>? cursor;
  PaginatedListedCouponsResult({required this.coupons, this.cursor});
}

class CouponRepository {
  final ApiClient _api;

  UserRepository userRepository = UserRepository();

  CouponRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  // ============ API-BASED METHODS ============

  // COUPON LIST METHODS ===========================

  /// Fetch coupons from personalized feed with cursor-based pagination
  Future<PaginatedCouponsResult> fetchCouponFeed({
    required int limit,
    String? cursor,
    required String userId,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
      };

      final response = await _api.get(
        '/coupons/feed',
        queryParameters: queryParams,
        useAuthToken: true,
      );
      
      if (response is Map<String, dynamic>) {
        final items = response['items'] as List?;
        final nextCursor = response['nextCursor'] as String?;
        
        if (items != null) {
          final coupons = await Future.wait(
            items.map((data) async => Coupon.availableToMeFromJson(data)),
          );
          return PaginatedCouponsResult(
            ownedCoupons: coupons.whereType<Coupon>().toList(),
            lastOffset: nextCursor != null ? 1 : null, // Use cursor for pagination
          );
        }
      } else if (response is List) {
        // Fallback for legacy response format
        final coupons = await Future.wait(
          response.map((data) async => Coupon.availableToMeFromJson(data)),
        );
        return PaginatedCouponsResult(
          ownedCoupons: coupons.whereType<Coupon>().toList(),
          lastOffset: response.length < limit ? null : 1,
        );
      }
      
      return PaginatedCouponsResult(ownedCoupons: [], lastOffset: null);
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchCouponFeed: $e');
      rethrow;
    }
  }

  /// Fetch coupons with pagination and filters (from active listings)
  Future<PaginatedCouponsResult> fetchCouponsPaginated({
    required int limit,
    Map<String, dynamic>? cursor,
    String? shopId,
    String? categoryId,
    required String userId,
    bool? reductionIsPercentage,
    bool? reductionIsFixed,
    double? minPrice,
    double? maxPrice,
    int? minReputation,
    String? sort, // e.g. "price+asc"
  }) async {
    try {
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        if (cursor != null) 'cursor_value': cursor['value']!.toString(),
        if (cursor != null) 'cursor_id': cursor['id']!.toString(),
        if (shopId != null) 'shop_id': shopId,
        if (categoryId != null && shopId == null) 'category_id': categoryId,
        if (reductionIsPercentage != null && !reductionIsFixed!) 'type': 'percent',
        if (reductionIsFixed != null && !reductionIsPercentage!) 'type': 'flat',
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (minReputation != null) 'min_rep': minReputation.toString(),
        if (sort != null) 'sort': sort,
      };

      final response = await _api.get(
        '/coupons/available',
        queryParameters: queryParams,
        useAuthToken: true,
      );
      
      if (kDebugMode) print('Response from fetchCouponsPaginated: ${response['data']}');
      if (response['data'] is List) {
        final coupons = response['data'].map((data) => Coupon.availableToMeFromJson(data));
        final cur = response['nextCursor'] != null ? Map<String, dynamic>.from(response['nextCursor']) : null;
        return PaginatedCouponsResult(
          ownedCoupons: coupons.whereType<Coupon>().toList(),
          cursor: cur,
        );
      }
      return PaginatedCouponsResult(ownedCoupons: [], cursor: null);
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch coupon details by ID
  Future<Coupon> fetchCouponDetailsById(String id) async {
    try {
      final data = await _api.get('/coupons/available/$id', useAuthToken: true);
      final coupon = Coupon.availableToMeFromJson(data as Map<String, dynamic>);

      return coupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchCouponDetailsById: $e');
      rethrow;
    }
  }
  
  // OWNED COUPON LIST METHODS =====================

  /// Fetch user's owned coupons (bought coupons) with pagination and filters
  Future<PaginatedOwnedCouponsResult> fetchOwnedCouponsPaginated({
    required int limit,
    Map<String, dynamic>? cursor,
    required String userId,
    bool? reductionIsPercentage,
    bool? reductionIsFixed,
    bool? showUsed,
    bool? showUnused,
    String? shopId,
    String? sort,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        if (cursor != null) 'cursor_value': cursor['value']!.toString(),
        if (cursor != null) 'cursor_id': cursor['id']!.toString(),
        'owner_id': userId,
        if (reductionIsPercentage != null && !reductionIsFixed!) 'type': 'percent',
        if (reductionIsFixed != null && !reductionIsPercentage!) 'type': 'flat',
        if (showUsed != null && !showUnused!) 'used': 'yes',
        if (showUnused != null && !showUsed!) 'used': 'no',
        if (shopId != null) 'shop_id': shopId,
        if (sort != null) 'sort': sort,
      };

      final response = await _api.get(
        '/coupons/owned',
        queryParameters: queryParams,
        useAuthToken: true,
      );
      if (response['data'] is List) {
        final coupons = response['data'].map((data) => Coupon.boughtByMeFromJson(data));
        final cur = response['nextCursor'] != null ? Map<String, dynamic>.from(response['nextCursor']) : null;
        return PaginatedOwnedCouponsResult(
          coupons: coupons.whereType<Coupon>().toList(),
          cursor: cur,
        );
      }
      return PaginatedOwnedCouponsResult(coupons: [], cursor: null);
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch owned coupon details by ID
  Future<Coupon> fetchOwnedCouponDetailsById(String id) async {
    try {
      final data = await _api.get(
        '/coupons/owned/$id',
        useAuthToken: true
      );
      final ownedCoupon = Coupon.boughtByMeFromJson(data as Map<String, dynamic>);

      return ownedCoupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponDetailsById: $e');
      rethrow;
    }
  }

  // LISTED COUPON LIST METHODS ====================

  /// Fetch listed coupons with pagination and filters (GET /coupons/listed)
  Future<PaginatedListedCouponsResult> fetchListedCouponsPaginated({
    required int limit,
    Map<String, dynamic>? cursor,
    required String userId,
    bool? reductionIsPercentage,
    bool? reductionIsFixed,
    bool? showActive,
    bool? showSold,
    String? shopId,
    String? sort,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        if (cursor != null) 'cursor_value': cursor['value']!.toString(),
        if (cursor != null) 'cursor_id': cursor['id']!.toString(),
        'seller_id': userId,
        if (reductionIsPercentage != null && !reductionIsFixed!) 'type': 'percent',
        if (reductionIsFixed != null && !reductionIsPercentage!) 'type': 'flat',
        if (showActive != null && !showSold!) 'status': 'active',
        if (showSold != null && !showActive!) 'status': 'sold',
        if (shopId != null) 'shop_id': shopId,
        if (sort != null) 'sort': sort,
      };

      final response = await _api.get(
        '/coupons/listed',
        queryParameters: queryParams,
        useAuthToken: true,
      );
      if (response['data'] is List) {
        final coupons = response['data'].map((data) => Coupon.listedByMeFromJson(data));
        final cur = response['nextCursor'] != null ? Map<String, dynamic>.from(response['nextCursor']) : null;
        return PaginatedListedCouponsResult(
          coupons: coupons.whereType<Coupon>().toList(),
          cursor: cur,
        );
      }
      return PaginatedListedCouponsResult(coupons: [], cursor: null);
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchListedCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch listed coupon details by ID (GET /coupons/listed/:id)
  Future<Coupon> fetchListedCouponDetailsById(String id, String userId) async {
    try {
      final data = await _api.get(
        '/coupons/listed/$id',
        useAuthToken: true
      );
      final coupon = Coupon.listedByMeFromJson( data as Map<String, dynamic>);

      return coupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchListedCouponDetailsById: $e');
      rethrow;
    }
  }

  // SAVED COUPON METHODS =======================

  /// Fetch user's listed coupons (GET /coupons/listed?seller_id={userId})
  Future<List<Map<String, dynamic>>> fetchSavedCouponsFromApi(String userId) async {
    try {
      final response = await _api.get(
        '/coupons/saved',
        useAuthToken: true
      );
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching saved coupons from API: $e');
      rethrow;
    }
  }

  /// Fetch saved coupons with pagination and filters (GET /coupons/listed)
  Future<PaginatedListedCouponsResult> fetchSavedCouponsPaginated({
    required int limit,
    Map<String, dynamic>? cursor,
    required String userId,
    bool? reductionIsPercentage,
    bool? reductionIsFixed,
    bool? showActive,
    bool? showSold,
    String? shopId,
    String? sort,
    String? status,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'limit': limit.toString(),
        if (cursor != null) 'cursor_value': cursor['value']!.toString(),
        if (cursor != null) 'cursor_id': cursor['id']!.toString(),
        'seller_id': userId,
        if (reductionIsPercentage != null && reductionIsPercentage) 'type': 'percent',
        if (reductionIsFixed != null && reductionIsFixed) 'type': 'flat',
        if (showActive != null && showActive) 'status': 'active',
        if (showSold != null && showSold) 'status': 'sold',
        if (shopId != null) 'shop_id': shopId,
        if (sort != null) 'sort': sort,
        if (status != null) 'status': status,
      };

      final response = await _api.get(
        '/coupons/listed',
        queryParameters: queryParams,
        useAuthToken: true,
      );
      if (response['data'] is List) {
        final coupons = response['data'].map((data) => Coupon.listedByMeFromJson(data));
        final cur = response['nextCursor'] != null ? Map<String, dynamic>.from(response['nextCursor']) : null;
        return PaginatedListedCouponsResult(
          coupons: coupons.whereType<Coupon>().toList(),
          cursor: cur,
        );
      }
      return PaginatedListedCouponsResult(coupons: [], cursor: null);
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchSavedCouponsPaginated: $e');
      rethrow;
    }
  }

    /// Add a coupon to the saved list (POST /coupons/saved/:coupon_id)
  Future<void> addCouponToSaved({required String couponId, required String userId}) async {
    try {
      await _api.post(
        '/coupons/saved/$couponId',
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding coupon to saved: $e');
      rethrow;
    }
  }

  /// Remove a coupon from the saved list (DELETE /coupons/saved/:coupon_id)
  Future<void> removeCouponFromSaved({required String couponId, required String userId}) async {
    try {
      await _api.delete(
        '/coupons/saved/$couponId',
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error removing coupon from saved: $e');
      rethrow;
    }
  }
  
  // GENERAL METHODS ===============================

  /// Create new coupon offer via API (POST /coupons)
  Future<void> postCouponOffer(CouponOffer coupon) async {
    try {
      await _api.post(
        '/coupons',
        body: coupon.toJson(), 
        useAuthToken: true,
        );
    } catch (e) {
      if (kDebugMode) debugPrint('Error posting coupon: $e');
      rethrow;
    }
  }
  
  /// Deactivate listed coupon via API (DELETE /coupons/{couponId})
  Future<void> deactivateListedCoupon(String couponId) async {
    try {
      await _api.delete(
        '/coupons/$couponId', 
        useAuthToken: true,
        );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in deactivateListedCoupon: $e');
      rethrow;
    }
  }

  /// Fetch three coupons for a specific shop
  Future<List<Coupon>> fetchThreeCouponsForShop(String shopId) async {
    try {
      final result = await fetchCouponsPaginated(limit: 3, shopId: shopId, userId: await userRepository.getCurrentUserId());
      return result.ownedCoupons;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchThreeCouponsForShop: $e');
      rethrow;
    }
  }


  // RECOMENDATIONS BELOW

  //Record a click
  Future<void> recordCouponClick(String couponId) async {
    if(kDebugMode) print('Recording click for couponId: $couponId');
    try {
      final userId = await userRepository.getCurrentUserId();
      await _api.post(
        '/events/click',
        body: {'couponId': couponId},
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error recording coupon click: $e');
      rethrow;
    }
  }

}