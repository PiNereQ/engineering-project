import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/listed_coupon_model.dart';
import 'listed_coupon_list_event.dart';

abstract class ListedCouponListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListedCouponListInitial extends ListedCouponListState {}

class ListedCouponListLoadInProgress extends ListedCouponListState {}

class ListedCouponListLoadSuccess extends ListedCouponListState {
  final List<ListedCoupon> coupons;
  final bool hasMore;

  ListedCouponListLoadSuccess({
    required this.coupons,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [coupons, hasMore];
}

class ListedCouponListLoadEmpty extends ListedCouponListState {}

class ListedCouponListLoadFailure extends ListedCouponListState {
  final String message;

  ListedCouponListLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ListedCouponFilterRead extends ListedCouponListState {
  final bool? reductionIsPercentage;
  final bool? reductionIsFixed;
  final bool? showActive;
  final bool? showSold;
  final String? shopId;

  ListedCouponFilterRead({
    this.reductionIsPercentage,
    this.reductionIsFixed,
    this.showActive,
    this.showSold,
    this.shopId,
  });
}

class ListedCouponOrderingRead extends ListedCouponListState {
  final ListedCouponsOrdering ordering;

  ListedCouponOrderingRead(this.ordering);
}