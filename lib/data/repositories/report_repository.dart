import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/api/api_client.dart';

class ReportRepository {
  final ApiClient _api;

  ReportRepository({ApiClient? api})
      : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  Future<void> createReport({
    required String reportedUserId,
    String? couponId,
    required String reportReason,
    String? reportDetails,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final body = {
      'reporter_id': currentUser.uid,
      'reported_user_id': reportedUserId,
      if (couponId != null) 'coupon_id': couponId,
      'report_reason': reportReason,
      if (reportDetails != null && reportDetails.isNotEmpty)
        'report_details': reportDetails,
    };

    await _api.post(
      '/reports',
      body: body,
      useAuthToken: true,
    );
  }
}