part of 'coupon_map_bloc.dart';

const _noChange = Object();

enum CouponMapStatus {
  initial,
  loading,
  success,
  failure,
}

class CouponMapState extends Equatable {
  final CouponMapStatus status;
  final List<ShopLocation> locations;
  final List<Coupon> selectedShopLocationCoupons;
  final String? errorMessage;
  final bool showSearchButton;
  final bool showZoomTip;
  final String? selectedShopLocationId;
  final String? selectedShopId;
  final String? selectedShopName;

  const CouponMapState({
    this.status = CouponMapStatus.initial,
    this.locations = const [],
    this.selectedShopLocationCoupons = const [],
    this.errorMessage,
    this.showSearchButton = false,
    this.showZoomTip = true,
    this.selectedShopLocationId,
    this.selectedShopId,
    this.selectedShopName,
  });

  CouponMapState copyWith({
    CouponMapStatus? status,
    List<ShopLocation>? locations,
    List<Coupon>? selectedShopLocationCoupons,
    String? errorMessage,
    bool? showSearchButton,
    bool? showZoomTip,
    Object? selectedShopLocationId = _noChange,
    Object? selectedShopId = _noChange,
    Object? selectedShopName = _noChange,
  }) {
    return CouponMapState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      selectedShopLocationCoupons:
          selectedShopLocationCoupons ?? this.selectedShopLocationCoupons,
      errorMessage: errorMessage ?? this.errorMessage,
      showSearchButton: showSearchButton ?? this.showSearchButton,
      showZoomTip: showZoomTip ?? this.showZoomTip,
      // Only change selectedShopLocationId when an explicit value is provided.
      selectedShopLocationId:
          identical(selectedShopLocationId, _noChange)
              ? this.selectedShopLocationId
              : selectedShopLocationId as String?,
      selectedShopId:
          identical(selectedShopId, _noChange)
              ? this.selectedShopId
              : selectedShopId as String?,
      selectedShopName:
          identical(selectedShopName, _noChange)
              ? this.selectedShopName
              : selectedShopName as String?,
    );
  }
  
  @override
  List<Object?> get props => [
    status,
    locations,
    selectedShopLocationCoupons,
    errorMessage,
    showSearchButton,
    showZoomTip,
    selectedShopLocationId,
    selectedShopId,
    selectedShopName,
  ];
}