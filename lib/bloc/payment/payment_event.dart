part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class StartPayment extends PaymentEvent {
  final Listing listing;
  final String buyerId;
  final int amount; // Amount in smallest currency unit (e.g., 6800 for 68.00 PLN)

  const StartPayment({
    required this.listing,
    required this.buyerId,
    required this.amount,
  });

  @override
  List<Object?> get props => [listing, buyerId, amount];
}