import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapRepository {
  Future<List<Location>> fetchLocations() async {
    // TODO: Replace with fetching from API
    await Future.delayed(Duration(seconds: 1));
    return [
      Location(shopLocationId: '0', latitude: 52.406374, longitude: 16.925168, shopId: '1', shopName: 'Media Expert'),
      Location(shopLocationId: '1', latitude: 52.406554, longitude: 16.925334, shopId: '3', shopName: 'MediaMarkt'),
      Location(shopLocationId: '2', latitude: 52.467139, longitude: 16.927121, shopId: '1', shopName: 'Media Expert'),
    ];
  }

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