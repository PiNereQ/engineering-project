part of 'coupon_add_bloc.dart';

sealed class CouponAddState extends Equatable {
  const CouponAddState();
  
  @override
  List<Object> get props => [];
}

final class CouponAddInitial extends CouponAddState {}

final class CouponAddInProgress extends CouponAddState {
  final bool isLoading;

  const CouponAddInProgress({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

final class CouponAddSuccess extends CouponAddState {}

final class CouponAddFailure extends CouponAddState {
  final Object error;

  const CouponAddFailure({required this.error});

  @override
  List<Object> get props => [error];
}