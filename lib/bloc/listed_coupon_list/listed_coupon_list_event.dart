
import 'package:equatable/equatable.dart';

abstract class ListedCouponListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchListedCoupons extends ListedCouponListEvent {}

class FetchMoreListedCoupons extends ListedCouponListEvent {}

class RefreshListedCoupons extends ListedCouponListEvent {}

class ApplyListedCouponFilters extends ListedCouponListEvent {
  final bool reductionIsPercentage;
  final bool reductionIsFixed;
  final bool showActive;
  final bool showSold;
  final String? shopId;

  ApplyListedCouponFilters({
    required this.reductionIsPercentage,
    required this.reductionIsFixed,
    required this.showActive,
    required this.showSold,
    required this.shopId,
  });
}

class ClearListedCouponFilters extends ListedCouponListEvent {}

class ReadListedCouponFilters extends ListedCouponListEvent {}

class ApplyListedCouponOrdering extends ListedCouponListEvent {
  final ListedCouponsOrdering ordering;

  ApplyListedCouponOrdering(this.ordering);
}

class ReadListedCouponOrdering extends ListedCouponListEvent {}

enum ListedCouponsOrdering {
  listingDateDesc,
  listingDateAsc,
  expiryDateAsc,
  expiryDateDesc,
  priceAsc,
  priceDesc,
}