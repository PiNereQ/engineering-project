import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<StartPayment>((event, emit) async {
      emit(PaymentInProgress());
      try {
        final response = await http.post(
          Uri.parse('http://49.13.155.21:8000/payments/create-payment-intent'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'amount': event.amount}), // smallest currency unit, e.g., 1999 = 19.99 PLN
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to create PaymentIntent: ${response.body}');
        }

        final data = jsonDecode(response.body);
        final clientSecret = data['clientSecret'];


        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Coupidyn',
          ),
        );
        await Stripe.instance.presentPaymentSheet();
        emit(PaymentSuccess());
      } on StripeException catch (e) {
        if (e.error.code == FailureCode.Canceled) {
          emit(const PaymentFailure(error: "Płatność została anulowana."));
        }
      } catch (e) {
        emit(PaymentFailure(error: "Błąd płatności: ${e.toString()}"));
      }
    });
  }


}