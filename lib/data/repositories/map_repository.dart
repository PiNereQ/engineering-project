import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:proj_inz/data/api/api_client.dart';

class MapRepository {
  final ApiClient _api;

  MapRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Fetch all locations from API (GET /shops and extract locations)
  Future<List<Location>> fetchLocations() async {
    try {
      final response = await _api.getJson('/shops');
      final List<dynamic> shopsData = response is List ? response : [];
      
      final locations = <Location>[];
      
      for (var shopData in shopsData) {
        final shopId = shopData['id'].toString();
        final shopName = shopData['name'] as String;
        
        // Fetch detailed shop info to get locations
        try {
          final shopDetail = await _api.getJsonById('/shops', shopId);
          final shopLocations = shopDetail['locations'] as List?;
          
          if (shopLocations != null) {
            for (var loc in shopLocations) {
              locations.add(Location(
                shopLocationId: loc['id'].toString(),
                latitude: (loc['latitude'] as num).toDouble(),
                longitude: (loc['longitude'] as num).toDouble(),
                shopId: shopId,
                shopName: shopName,
              ));
            }
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Error fetching locations for shop $shopId: $e');
        }
      }
      
      return locations;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching locations: $e');
      rethrow;
    }
  }

  /// Fetch locations within specific bounds
  Future<List<Location>> fetchLocationsInBounds(LatLngBounds bounds) async {
    final allLocations = await fetchLocations();
    return allLocations.where((location) {
      return bounds.contains(LatLng(location.latitude, location.longitude));
    }).toList();
  }
}

class Location {
  final String shopLocationId;
  final double latitude;
  final double longitude;
  final String shopId;
  final String? shopName;

  Location({
    required this.shopLocationId,
    required this.latitude,
    required this.longitude,
    required this.shopId,
    this.shopName,
  });
}