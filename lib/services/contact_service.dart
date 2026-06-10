import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';

class ContactService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> sendMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.contact,
        data: {
          'name': name,
          'email': email,
          'message': message,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to send message';

      throw Exception(message);
    }
  }
}