part of 'coupon_list_bloc.dart';

sealed class CouponListState extends Equatable {
  const CouponListState();
  
  @override
  List<Object> get props => [];
}

final class CouponListInitial extends CouponListState {}

final class CouponListLoadInProgress extends CouponListState {}

class CouponListLoadSuccess extends CouponListState {
  final List<Coupon> coupons;
  final bool hasMore;

  const CouponListLoadSuccess({required this.coupons, required this.hasMore});

  @override
  List<Object> get props => [coupons];
}

class CouponListLoadFailure extends CouponListState {
  final String message;

  const CouponListLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

final class CouponListLoadEmpty extends CouponListState {}

class CouponListFilterApplyInProgress extends CouponListState {}

class CouponListFilterApplySuccess extends CouponListState {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final double? minPrice;
  final double? maxPrice;
  final int? minReputation;

  const CouponListFilterApplySuccess(
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.minPrice,
    this.maxPrice, 
    this.minReputation);
}

class CouponListFilterApplyFailure extends CouponListState {
  final String message;

  const CouponListFilterApplyFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class CouponListFilterRead extends CouponListState {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final double? minPrice;
  final double? maxPrice;
  final int? minReputation;

  const CouponListFilterRead({
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.minPrice,
    this.maxPrice, 
    this.minReputation});
}

class CouponListOrderingApplyInProgress extends CouponListState {}

class CouponListOrderingApplySuccess extends CouponListState {
  final Ordering ordering;

  const CouponListOrderingApplySuccess(this.ordering);

  @override
  List<Object> get props => [ordering];
}
class CouponListOrderingApplyFailure extends CouponListState {
  final String message;

  const CouponListOrderingApplyFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class CouponListOrderingRead extends CouponListState {
  final Ordering ordering;

  const CouponListOrderingRead(this.ordering);

  @override
  List<Object> get props => [ordering];
}