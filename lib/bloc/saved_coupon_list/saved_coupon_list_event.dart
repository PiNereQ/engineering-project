part of 'saved_coupon_list_bloc.dart';

sealed class SavedCouponListEvent extends Equatable {
  const SavedCouponListEvent();

  @override
  List<Object?> get props => [];
}

class FetchSavedCoupons extends SavedCouponListEvent {
  final String userId;
  const FetchSavedCoupons({required this.userId});

  @override
  List<Object> get props => [userId];
}

class FetchMoreSavedCoupons extends SavedCouponListEvent {}

class RefreshSavedCoupons extends SavedCouponListEvent {
  final String userId;
  const RefreshSavedCoupons({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ApplySavedCouponFilters extends SavedCouponListEvent {
  final bool reductionIsPercentage;
  final bool reductionIsFixed;
  final String? shopId;
  final double? minPrice;
  final double? maxPrice;
  final double? minReputation;

  const ApplySavedCouponFilters({
    required this.reductionIsPercentage,
    required this.reductionIsFixed,
    required this.shopId,
    this.minPrice,
    this.maxPrice,
    this.minReputation,
  });
}

class ClearSavedCouponFilters extends SavedCouponListEvent {}

class ReadSavedCouponFilters extends SavedCouponListEvent {}

class ApplySavedCouponOrdering extends SavedCouponListEvent {
  final SavedCouponsOrdering ordering;

  const ApplySavedCouponOrdering(this.ordering);
}

class ReadSavedCouponOrdering extends SavedCouponListEvent {}

enum SavedCouponsOrdering {
  saveDateAsc,
  saveDateDesc,
  creationDateAsc,
  creationDateDesc,
  priceAsc,
  priceDesc,
  reputationAsc,
  reputationDesc,
  expiryDateAsc,
  expiryDateDesc,
}