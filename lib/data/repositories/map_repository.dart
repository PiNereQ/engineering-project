import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapRepository {
  Future<List<Location>> fetchLocations() async {
    // TODO: Replace with fetching from API
    await Future.delayed(Duration(seconds: 1));
    return [
      Location(latitude: 52.406374, longitude: 16.925168, name: 'A'),
      Location(latitude: 52.467139, longitude: 16.927121, name: 'B'),
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
  final double latitude;
  final double longitude;
  final String name;

  Location({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}