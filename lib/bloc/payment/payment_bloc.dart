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
        // 1. Call your backend to create a PaymentIntent
        final response = await http.post(
          Uri.parse('https://europe-west1-projektinzynierski-44c9d.cloudfunctions.net/createPaymentIntent'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'couponId': event.couponId,
            'userId': event.userId,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to create PaymentIntent');
        }

        final data = jsonDecode(response.body);
        final clientSecret = data['clientSecret'];

        // 2. Confirm payment with flutter_stripe
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Your App Name',
          ),
        );

        await Stripe.instance.presentPaymentSheet();
      } catch (e) {
        emit(PaymentFailure(error: e.toString()));
      }
    });
  }
}