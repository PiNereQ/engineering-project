part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class StartPayment extends PaymentEvent {
  final int amount;
  final String listingId;

  const StartPayment({required this.amount, required this.listingId});

  @override
  List<Object?> get props => [amount, listingId];
}