import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:proj_inz/data/api/api_client.dart';
import 'package:proj_inz/data/models/shop_location_model.dart';

class MapRepository {
  final ApiClient _api;

  MapRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Fetch locations within specific bounds from API (GET /shops/locations?latS=&lngW=&latN=&lngE=)
  Future<List<ShopLocation>> fetchLocationsInBounds(LatLngBounds bounds) async {
    try {
      final response = await _api.getJson('/shops/locations?south=${bounds.south}&west=${bounds.west}&north=${bounds.north}&east=${bounds.east}');
      final List<dynamic> locationsData = response is List ? response : [];
      final locations = <ShopLocation>[];
      for (var loc in locationsData) {
        print(loc);
        locations.add(ShopLocation(
          shopLocationId: loc['id'].toString(),
          latLng: LatLng(
            double.parse(loc['latitude'].toString()),
            double.parse(loc['longitude'].toString()),
          ),
          shopId: loc['shop_id'].toString(),
          shopName: loc['shop_name']?.toString(),
        ));
      }
      return locations;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching locations in bounds: $e');
      rethrow;
    }
  }
}