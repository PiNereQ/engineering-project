part of 'saved_coupon_list_bloc.dart';

sealed class SavedCouponListState extends Equatable {
  const SavedCouponListState();

  @override
  List<Object?> get props => [];
}

class SavedCouponListInitial extends SavedCouponListState {}

class SavedCouponListLoadInProgress extends SavedCouponListState {
  final List<Coupon>? coupons;

  const SavedCouponListLoadInProgress({this.coupons});

  @override
  List<Object?> get props => [coupons];
}

class SavedCouponListLoadSuccess extends SavedCouponListState {
  final List<Coupon> coupons;
  final bool hasMore;

  const SavedCouponListLoadSuccess({required this.coupons, this.hasMore = false});

  @override
  List<Object?> get props => [coupons, hasMore];
}

class SavedCouponListLoadEmpty extends SavedCouponListState {}

class SavedCouponListLoadFailure extends SavedCouponListState {
  final String message;

  const SavedCouponListLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class SavedCouponFilterRead extends SavedCouponListState {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final String? shopId;
  final double? minPrice;
  final double? maxPrice;
  final double? minReputation;

  const SavedCouponFilterRead({
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.shopId,
    this.minPrice,
    this.maxPrice,
    this.minReputation,
  });
}

class SavedCouponOrderingRead extends SavedCouponListState {
  final SavedCouponsOrdering ordering;

  const SavedCouponOrderingRead(this.ordering);
}