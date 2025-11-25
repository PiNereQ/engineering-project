import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

class GridCluster<T> {
  final LatLng center;
  final List<T> items;

  bool get isCluster => items.length > 1;

  const GridCluster({
    required this.center,
    required this.items,
  });
}

typedef LatLngExtractor<T> = LatLng Function(T item);

List<GridCluster<T>> clusterItems<T>(
  List<T> items, {
  required int zoom,
  required double cellSizePx,
  required LatLngExtractor<T> toLatLng,
}) {
  if (items.isEmpty) return const [];

  final double worldSize = 256 * math.pow(2, zoom).toDouble();

  math.Point<double> project(LatLng p) {
    // WebMercator projection to pixel coordinates.
    final x = (p.longitude + 180.0) / 360.0 * worldSize;

    final sinLat = math.sin(p.latitude * math.pi / 180);
    final y = (0.5 -
            0.25 /
                math.pi *
                math.log((1 + sinLat) / (1 - sinLat))) *
        worldSize;

    return math.Point<double>(x, y);
  }

  final Map<math.Point<int>, List<T>> cells = {};

  for (final item in items) {
    final ll = toLatLng(item);
    final pt = project(ll);
    final cell = math.Point<int>(
      (pt.x / cellSizePx).floor(),
      (pt.y / cellSizePx).floor(),
    );
    cells.putIfAbsent(cell, () => <T>[]).add(item);
  }

  return cells.entries.map((entry) {
    final pts = entry.value;

    double sumLat = 0;
    double sumLng = 0;
    for (final item in pts) {
      final ll = toLatLng(item);
      sumLat += ll.latitude;
      sumLng += ll.longitude;
    }

    final center = LatLng(
      sumLat / pts.length,
      sumLng / pts.length,
    );

    return GridCluster<T>(center: center, items: pts);
  }).toList();
}
