import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/dashboard_model.dart';
import 'package:proj_inz/data/api/api_client.dart';

class DashboardRepository {
  final ApiClient _api;

  DashboardRepository({ApiClient? api})
    : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Fetch dashboard data for a user
  Future<Dashboard> fetchDashboard() async {
    try {
      final response = await _api.get(
        '/events/recommendations/dashboard',
        useAuthToken: true,
      );

      if (kDebugMode) {
        debugPrint('Dashboard response: $response');
      }

      return Dashboard.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching dashboard: $e');
      }
      rethrow;
    }
  }
}
