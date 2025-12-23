import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:proj_inz/data/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc({required PaymentRepository paymentRepository}) 
      : _paymentRepository = paymentRepository,
        super(PaymentInitial()) {
    on<StartPayment>((event, emit) async {
      emit(PaymentInProgress());
      try {
        final paymentIntentData = await _paymentRepository.createPaymentIntent(
          amount: event.amount,
          couponId: event.couponId,
        );

        final clientSecret = paymentIntentData['clientSecret']!;
        final paymentIntentId = paymentIntentData['paymentIntentId']!;

        if (kDebugMode) {
          debugPrint('Payment intent created: $paymentIntentId');
        }

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Coupidyn',
          ),
        );
        await Stripe.instance.presentPaymentSheet();

        await _paymentRepository.confirmPayment(
          paymentIntentId: paymentIntentId,
          couponId: event.couponId,
          buyerId: event.buyerId,
          sellerId: event.sellerId,
          amount: event.amount,
          isMultipleUse: event.isMultipleUse,
        );

        emit(PaymentSuccess());
      } on StripeException catch (e) {
        await _paymentRepository.cancelPayment(couponId: event.couponId);
        if (e.error.code == FailureCode.Canceled) {
          emit(const PaymentFailure(error: "Płatność została anulowana."));
        } else {
          emit(PaymentFailure(error: "Błąd Stripe: ${e.error.message}"));
        }
      } catch (e) {
        emit(PaymentFailure(error: "Błąd płatności: ${e.toString()}"));
      }
    });
  }
}