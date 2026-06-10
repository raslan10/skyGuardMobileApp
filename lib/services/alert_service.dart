import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/alert_model.dart';

class AlertService {
  final Dio _dio = ApiClient().dio;

  Future<List<AlertModel>> getAlerts() async {
    try {
      final response = await _dio.get(
        ApiConstants.alerts,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List alertsList =
        data is Map<String, dynamic>
            ? data['alerts'] ?? []
            : data;

        return alertsList
            .map((e) => AlertModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load alerts');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load alerts';

      throw Exception(
        message ?? 'Failed to load alerts',
      );
    }
  }
}