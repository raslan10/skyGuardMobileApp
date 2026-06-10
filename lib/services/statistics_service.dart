import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/statistics_model.dart';

class StatisticsService {
  final Dio _dio = ApiClient().dio;

  Future<StatisticsModel> getStatistics() async {
    try {
      final response = await _dio.get(
        ApiConstants.statistics,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        return StatisticsModel.fromJson(
          data['statistics'],
        );
      } else {
        throw Exception('Failed to load statistics');
      }
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to load statistics';

      throw Exception(message);
    }
  }
}