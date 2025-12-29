import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/api/api_client.dart';

class WalletRepository {
  final ApiClient _api;

  WalletRepository({ApiClient? api})
      : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// GET /wallet/balance
  /// Authorization: Bearer <token>
  Future<int> getWalletBalance() async {
    try {
      final response = await _api.get(
        '/wallet/balance',
        useAuthToken: true,
        queryParameters: {},
      );

      if (response is Map && response.containsKey('balance')) {
        final balance = response['balance'];

        if (balance is int) {
          return balance;
        }

        if (balance is double) {
          return (balance * 100).round();
        }
      }

      throw Exception('Invalid wallet balance response');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching wallet balance: $e');
      }
      rethrow;
    }
  }
}