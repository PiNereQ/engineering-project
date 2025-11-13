class MapRepository {
  Future<List<Location>> fetchLocations() async {
    // Simulate fetching data from an API or database
    await Future.delayed(Duration(seconds: 1));
    return [
      Location(latitude: 52.406374, longitude: 16.925168, name: 'A'),
      Location(latitude: 52.467139, longitude: 16.927121, name: 'B'),
    ];
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