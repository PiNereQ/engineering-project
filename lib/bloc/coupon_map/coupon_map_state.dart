part of 'coupon_map_bloc.dart';

enum CouponMapStatus {
  initial,
  loading,
  success,
  failure,
}

class CouponMapState extends Equatable {
  final CouponMapStatus status;
  final List<Location> locations;
  final String? errorMessage;
  final bool showSearchButton;
  final bool showZoomTip;

  const CouponMapState({
    this.status = CouponMapStatus.initial,
    this.locations = const [],
    this.errorMessage,
    this.showSearchButton = false,
    this.showZoomTip = true,
  });

  CouponMapState copyWith({
    CouponMapStatus? status,
    List<Location>? locations,
    String? errorMessage,
    bool? showSearchButton,
    bool? showZoomTip,
  }) {
    return CouponMapState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
      showSearchButton: showSearchButton ?? this.showSearchButton,
      showZoomTip: showZoomTip ?? this.showZoomTip,
    );
  }
  
  @override
  List<Object?> get props => [
    status,
    locations,
    errorMessage,
    showSearchButton,
    showZoomTip,
  ];
}