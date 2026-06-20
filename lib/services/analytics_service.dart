import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';

class AnalyticsService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getAiAnalytics(String mediaId) async {
    try {
      // 🔄 إرسال الـ request للمسار الموحد الصحيح المربوط بجدول ai_predictions
      final response = await _dio.get(
        '${ApiConstants.aiAnalytics}/$mediaId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load AI analytics');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load AI analytics';
      throw Exception(message ?? 'Failed to load AI analytics');
    }
  }
}