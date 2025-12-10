part of 'owned_coupon_list_bloc.dart';

sealed class OwnedCouponListEvent extends Equatable {
  const OwnedCouponListEvent();

  @override
  List<Object?> get props => [];
}

class FetchCoupons extends OwnedCouponListEvent {}

class FetchMoreCoupons extends OwnedCouponListEvent {}

class RefreshCoupons extends OwnedCouponListEvent {}

// filters
class ReadOwnedCouponFilters extends OwnedCouponListEvent {}

class ApplyOwnedCouponFilters extends OwnedCouponListEvent {
  final bool reductionIsPercentage;
  final bool reductionIsFixed;
  final double? minPrice;
  final double? maxPrice;
  final String? shopId;
  final bool showUsed;
  final bool showUnused;

  const ApplyOwnedCouponFilters({
    required this.reductionIsPercentage,
    required this.reductionIsFixed,
    this.minPrice,
    this.maxPrice,
    this.shopId,
    required this.showUsed,
    required this.showUnused,
  });
}

class ClearOwnedCouponFilters extends OwnedCouponListEvent {}

class LeaveOwnedCouponFilterPopUp extends OwnedCouponListEvent {}

// sorting
class ReadOwnedCouponOrdering extends OwnedCouponListEvent {}

class ApplyOwnedCouponOrdering extends OwnedCouponListEvent {
  final OwnedCouponsOrdering ordering;
  const ApplyOwnedCouponOrdering(this.ordering);
}

class LeaveOwnedCouponSortPopUp extends OwnedCouponListEvent {}