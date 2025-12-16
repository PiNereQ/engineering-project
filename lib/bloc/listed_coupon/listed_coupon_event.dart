part of 'listed_coupon_bloc.dart';

sealed class ListedCouponEvent extends Equatable {
  const ListedCouponEvent();

  @override
  List<Object> get props => [];
}

class FetchCouponDetails extends ListedCouponEvent {
  final String userId;
  const FetchCouponDetails({required this.userId});

  @override
  List<Object> get props => [userId];
}