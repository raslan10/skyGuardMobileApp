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
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.sos,
        data: {
          'email': email,
          'latitude': latitude,
          'longitude': longitude,
          'message': message,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to send SOS';

      throw Exception(message);
    }
  }
}