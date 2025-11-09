part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class StartPayment extends PaymentEvent {
  final int amount;

  const StartPayment({required this.amount});

  @override
  List<Object?> get props => [amount];
}