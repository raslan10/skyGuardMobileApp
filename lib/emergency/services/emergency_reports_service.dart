import 'package:dio/dio.dart';

import '../../core-api/network/api_client.dart';
import '../models/emergency_report.dart';

class EmergencyReportsService {
  final Dio _dio = ApiClient().dio;

  Future<List<EmergencyReport>> getReports() async {
    try {
      final response = await _dio.get(
        '/emergency-reports',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List reportsList =
        data is Map<String, dynamic>
            ? data['reports'] ?? data['emergencyReports'] ?? []
            : data;

        return reportsList
            .map((e) => EmergencyReport.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load emergency reports');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load emergency reports';

      throw Exception(
        message ?? 'Failed to load emergency reports',
      );
    }
  }
}