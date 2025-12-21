import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/api/api_client.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

class PaginatedCouponsResult {
  final List<Coupon> ownedCoupons;
  final int? lastOffset;
  PaginatedCouponsResult({required this.ownedCoupons, this.lastOffset});
}

class PaginatedOwnedCouponsResult {
  final List<Coupon> coupons;
  final int? lastOffset;
  PaginatedOwnedCouponsResult({required this.coupons, this.lastOffset});
}

class PaginatedListedCouponsResult {
  final List<Coupon> coupons;
  final int? lastOffset;
  PaginatedListedCouponsResult({required this.coupons, this.lastOffset});
}

class CouponRepository {
  final ApiClient _api;

  UserRepository userRepository = UserRepository();

  CouponRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  // ============ API-BASED METHODS ============

  // COUPON LIST METHODS ===========================

  /// Fetch all coupons from API (GET /coupons)
  Future<List<Map<String, dynamic>>> fetchAllCouponsFromApi() async {
    try {
      final response = await _api.get('/coupons/available', useAuthToken: true);
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching coupons from API: $e');
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
      // TODO: move pagination to backend
      // TODO: move filtering and sorting to backend
      final listingsData = await fetchAllCouponsFromApi();
      
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
        paginated.map((data) async => Coupon.availableToMeFromJson(data))
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

  /// Fetch user's owned coupons (bought coupons) from API (GET /owned-coupons?owner_id={userId})
  Future<List<Map<String, dynamic>>> fetchOwnedCouponsFromApi(String userId) async {
    try {
      final response = await _api.get(
        '/coupons/owned',
        queryParameters: {'user_id': userId},
        useAuthToken: true
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
        paginated.map((data) async => Coupon.boughtByMeFromJson(data))
      );
      
      return PaginatedOwnedCouponsResult(
        coupons: coupons.whereType<Coupon>().toList(),
        lastOffset: end < ownedCouponsData.length ? end : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchOwnedCouponsPaginated: $e');
      rethrow;
    }
  }

  /// Fetch owned coupon details by ID
  Future<Coupon> fetchOwnedCouponDetailsById(String id) async {
    try {
      final userId = await userRepository.getCurrentUserId();
      final data = await _api.get(
        '/coupons/owned/$id',
        queryParameters: {"user_id": userId},
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
  
  /// Fetch user's listed coupons (GET /coupons/listed?seller_id={userId})
  Future<List<Map<String, dynamic>>> fetchListedCouponsFromApi(String userId) async {
    try {
      final response = await _api.get(
        '/coupons/listed',
        queryParameters: {'user_id': userId},
        useAuthToken: true
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
        paginated.map((data) async => Coupon.listedByMeFromJson(data)),
      );
      return PaginatedListedCouponsResult(
        coupons: coupons.whereType<Coupon>().toList(),
        lastOffset: end < listedCouponsData.length ? end : null,
      );
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
        queryParameters: {'user_id': userId},
        useAuthToken: true
      );
      final coupon = Coupon.listedByMeFromJson( data as Map<String, dynamic>);

      return coupon;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchListedCouponDetailsById: $e');
      rethrow;
    }
  }

  
  // GENERAL METHODS ===============================

  /// Create new coupon offer via API (POST /coupons)
  Future<void> postCouponOffer(CouponOffer coupon) async {
    try {
      final userId = await userRepository.getCurrentUserId();
      await _api.post(
        '/coupons',
        body: coupon.toJson(), 
        useAuthToken: true,
        queryParameters: {"user_id": userId}
        );
    } catch (e) {
      if (kDebugMode) debugPrint('Error posting coupon: $e');
      rethrow;
    }
  }
  
  /// Deactivate listed coupon via API (DELETE /coupons/{couponId})
  Future<void> deactivateListedCoupon(String couponId) async {
    try {
      final userId = await userRepository.getCurrentUserId();
      await _api.delete(
        '/coupons/$couponId', 
        useAuthToken: true,
        queryParameters: {"user_id": userId}
        );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in deactivateListedCoupon: $e');
      rethrow;
    }
  }

  /// Fetch three coupons for a specific shop
  Future<List<Coupon>> fetchThreeCouponsForShop(String shopId) async {
    try {
      final userId = await userRepository.getCurrentUserId();
      final result = await fetchCouponsPaginated(limit: 3, shopId: shopId);
      return result.ownedCoupons;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in fetchThreeCouponsForShop: $e');
      rethrow;
    }
  }

}