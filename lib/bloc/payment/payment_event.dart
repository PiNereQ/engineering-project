part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class StartPayment extends PaymentEvent {
  final String couponId;
  final String userId;

  const StartPayment({required this.couponId, required this.userId});

  @override
  List<Object?> get props => [couponId, userId];
}