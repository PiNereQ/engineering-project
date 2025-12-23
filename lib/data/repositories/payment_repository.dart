import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/api/api_client.dart';

class PaymentRepository {
  final ApiClient _api;

  PaymentRepository({ApiClient? api}) 
      : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Create payment intent via API (POST /payments/create-payment-intent)
  /// Returns a map with both clientSecret and paymentIntentId
  Future<Map<String, String>> createPaymentIntent({
    required int amount,
    required String couponId,
  }) async {
    try {
      final response = await _api.post(
        '/payments/create-payment-intent',
        body: {
          'amount': amount,
          'couponId': couponId,
        },
        useAuthToken: true,
      );
      return {
        'clientSecret': response['clientSecret'] as String,
        'paymentIntentId': response['paymentIntentId'] as String,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Confirm payment via API (POST /payments/confirm-payment)
  Future<void> confirmPayment({
    required String paymentIntentId,
    required String couponId,
    required String buyerId,
    required String sellerId,
    required int amount,
    required bool isMultipleUse,
  }) async {
    try {
      await _api.post(
        '/payments/confirm-payment',
        body: {
          'paymentIntentId': paymentIntentId,
          'couponId': couponId,
          'buyerId': buyerId,
          'sellerId': sellerId,
          'price': amount,
          'isMultipleUse': isMultipleUse,
        },
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error confirming payment: $e');
      rethrow;
    }
  }

  /// Cancel payment via API (POST /payments/cancel-payment)
  Future<void> cancelPayment({required String couponId}) async {
    try {
      await _api.post(
        '/payments/cancel-payment',
        body: {'couponId': couponId},
        useAuthToken: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error canceling payment: $e');
      rethrow;
    }
  }
}