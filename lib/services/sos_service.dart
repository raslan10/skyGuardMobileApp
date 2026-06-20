import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';

class SosService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> sendSos({
    required String email,
    required double latitude,
    required double longitude,
    required String message,
    // ✨ المتغيرات الجديدة الخاصة بـ Emergency System 2.0
    required double speed,
    required String accidentTime,
    required String mapLink,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.sos,
        data: {
          'email': email,
          'latitude': latitude,
          'longitude': longitude,
          'message': message,
          // 🧠 إرسال الداتا الجديدة في الـ Request Body للباك آند
          'speed': speed,
          'accident_time': accidentTime,
          'map_link': mapLink,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : e.response?.data.toString();

      throw Exception(message ?? 'Failed to send SOS');
    }
  }
}