import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';

class FcmApiService {
  final Dio _dio = ApiClient().dio;

  Future<void> saveFcmToken({
    required String email,
    required String fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.fcmToken,
        data: {
          'email': email,
          'fcmToken': fcmToken,
        },
      );

      print(
        'SAVE FCM TOKEN STATUS: ${response.statusCode}',
      );

      print(
        'SAVE FCM TOKEN BODY: ${response.data}',
      );
    } on DioException catch (e) {
      print(
        'SAVE FCM TOKEN ERROR: ${e.response?.data}',
      );
    }
  }

  Future<Map<String, dynamic>> sendTestNotification({
    required String email,
    required String title,
    required String body,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendTestNotification,
        data: {
          'email': email,
          'title': title,
          'body': body,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to send notification';

      throw Exception(message);
    }
  }
}