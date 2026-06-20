import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/models/analytics_model.dart'; // تأكد إن الموديل موجود هنا

class AnalyticsService {
  final Dio _dio = ApiClient().dio;

  // 1️⃣ الدالة القديمة (سيبناها زي ما هي عشان الشاشات القديمة ومطلعش إيرور)
  Future<AnalyticsModel> getAiAnalyticsLegacy() async {
    try {
      // هنا تقدر تحط المسار القديم أو تسيبها ترجع موديل فاضي لو مش بتستخدموها
      final response = await _dio.get('/ai-analytics-legacy');
      if (response.statusCode == 200) {
        return AnalyticsModel.fromJson(response.data['analytics']);
      }
      throw Exception('Failed to load AI analytics');
    } catch (e) {
      throw Exception('Failed to load AI analytics');
    }
  }

  // 2️⃣ ✨ الدالة الجديدة الحية اللي شغالين بيها في الـ Crash Analytics ومستنية الـ reportId
  Future<Map<String, dynamic>> getAiAnalytics(String reportId) async {
    try {
      final response = await _dio.get(
        '/emergency/reports/$reportId/ai-analytics',
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