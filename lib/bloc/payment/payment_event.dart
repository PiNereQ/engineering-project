part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class StartPayment extends PaymentEvent {
  final String couponId;
  final String buyerId;
  final String sellerId;
  final int amount; // Amount in smallest currency unit (e.g., 6800 for 68.00 PLN)

  const StartPayment({
    required this.couponId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
  });

  @override
  List<Object?> get props => [couponId, buyerId, amount];
}