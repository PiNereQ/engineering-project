import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/api/api_client.dart';

class ShopRepository {
  final ApiClient _api;
  final _shopCache = <String, Shop>{};

  ShopRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Fetch shop by ID from API (GET /shops/{id})
  Future<Shop> fetchShopById(String shopId) async {
    if (_shopCache.containsKey(shopId)) {
      return _shopCache[shopId]!;
    }

    try {
      final data = await _api.get('/shops/$shopId');
      
      final shop = Shop(
        id: data['id'].toString(),
        name: data['name'] as String,
        bgColor: _parseColor(data['bg_color']),
        nameColor: _parseColor(data['name_color']),
        categoryIds: [], // Categories are in separate relation, can be parsed from data['categories']
      );

      _shopCache[shopId] = shop;
      return shop;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching shop with ID $shopId: $e');
      rethrow;
    }
  }

  /// Fetch all shops from API (GET /shops)
  Future<List<Shop>> fetchAllShops() async {
    try {
      final response = await _api.get('/shops');
      final List<dynamic> shopsData = response is List ? response : [];

      final shops = shopsData.map((data) {
        return Shop(
          id: data['id'].toString(),
          name: data['name'] as String,
          bgColor: _parseColor(data['bg_color']),
          nameColor: _parseColor(data['name_color']),
          categoryIds: [],
        );
      }).toList();

      for (final shop in shops) {
        _shopCache[shop.id] = shop;
      }

      return shops;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching all shops: $e');
      rethrow;
    }
  }

  /// Search shops by name (client-side filtering for now)
  Future<List<Shop>> searchShopsByName(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final allShops = await fetchAllShops();
      final lowercaseQuery = query.toLowerCase();
      
      return allShops.where((shop) => 
        shop.name.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching shops: $e');
      rethrow;
    }
  }

  /// Parse color from hex string to int
  int _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return 0xFF000000;
    
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if not present
      }
      return int.parse(hex, radix: 16);
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing color $hexColor: $e');
      return 0xFF000000;
    }
  }

  void clearCache() {
    _shopCache.clear();
  }
}
