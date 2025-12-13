import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class ShopLocation extends Equatable {
  final String shopLocationId;
  final LatLng latLng;
  final String shopId;
  final String? shopName;

  const ShopLocation({
    required this.shopLocationId,
    required this.latLng,
    required this.shopId,
    this.shopName,
  });

  @override
  List<Object?> get props => [
        shopLocationId,
        latLng,
        shopId,
        shopName,
      ];
}