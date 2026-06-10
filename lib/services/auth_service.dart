import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core-api/network/api_client.dart';
import '../core-api/network/api_constants.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  final FlutterSecureStorage secureStorage =
  const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 &&
          data['success'] == true) {
        await secureStorage.write(
          key: 'token',
          value: data['token'] ?? '',
        );

        await secureStorage.write(
          key: 'user_email',
          value: data['user']?['email'] ?? email,
        );

        await secureStorage.write(
          key: 'user_name',
          value: data['user']?['name'] ?? '',
        );

        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(
          data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Login failed';

      throw Exception(
        message ?? 'Login failed',
      );
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(
          data['message'] ?? 'Register failed',
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Register failed';

      throw Exception(
        message ?? 'Register failed',
      );
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyEmail,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(
          data['message'] ?? 'Verification failed',
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Verification failed';

      throw Exception(
        message ?? 'Verification failed',
      );
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'user_name');
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  Future<String?> getUserEmail() async {
    return await secureStorage.read(
      key: 'user_email',
    );
  }

  Future<String?> getUserName() async {
    return await secureStorage.read(
      key: 'user_name',
    );
  }
}