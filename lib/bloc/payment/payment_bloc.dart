import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:proj_inz/data/models/listing_model.dart';
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
          body: jsonEncode({
            'amount': event.amount, // smallest currency unit, e.g., 1999 = 19.99 PLN
            'listingId': event.listing.id,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to create PaymentIntent: ${response.body}');
        }

        final data = jsonDecode(response.body);
        final clientSecret = data['clientSecret'];
        final paymentIntentId = data['paymentIntentId'];
        
        if (kDebugMode) {
          debugPrint('Payment intent created: $paymentIntentId');
          debugPrint('Response data: $data');
        }


        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Coupidyn',
          ),
        );
        await Stripe.instance.presentPaymentSheet();

        // Payment succeded here, else exception would be thrown

        final confirmResponse = await http.post(
          Uri.parse('http://49.13.155.21:8000/payments/confirm-payment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'paymentIntentId': paymentIntentId,
            'listingId': event.listing.id,
            'couponId': event.listing.couponId,
            'buyerId': event.buyerId,
            'sellerId': event.listing.sellerId,
            'price': event.listing.price,
            'isMultipleUse': event.listing.isMultipleUse,
          }),
        );

        if (confirmResponse.statusCode == 201 || confirmResponse.statusCode == 200) {
          emit(PaymentSuccess());
        } else {
          throw Exception('Confirmation failed: ${confirmResponse.body}');
        }
      } on StripeException catch (e) {
        await http.post(
          Uri.parse('http://49.13.155.21:8000/payments/cancel-payment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'listingId': event.listing.id}),
        );
        if (e.error.code == FailureCode.Canceled) {
          emit(const PaymentFailure(error: "Płatność została anulowana."));
        }
      } catch (e) {
        emit(PaymentFailure(error: "Błąd płatności: ${e.toString()}"));
      }
    });
  }
}