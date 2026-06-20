import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core-api/network/api_client.dart';
import '../core-api/network/api_constants.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // 🔑 تسجيل الدخول وحفظ البيانات والـ Role محلياً بشكل آمن
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

      if (response.statusCode == 200 && data['success'] == true) {
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

        // ✨ حفظ الـ Role الراجع من السيرفر محلياً (إما user أو admin)
        await secureStorage.write(
          key: 'user_role',
          value: data['user']?['role'] ?? 'user',
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

  // 📝 تسجيل حساب جديد مع تحديد الـ Role (User / Admin)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role, // ✨ الـ role المختار من الشاشة
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role, // 🔥 إرسال الـ role المختار للباك آند
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data['success'] == true) {
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

  // ✉️ تفعيل الحساب عبر الـ OTP
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

      if (response.statusCode == 200 && data['success'] == true) {
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

  // 🔥 استعادة كلمة المرور المنسية (Emergency Auth 2.0)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to send reset link';
      throw Exception(message ?? 'Failed to send reset link');
    }
  }

  // 🚪 تسجيل الخروج وتصفير التوكن وجميع البيانات المسجلة
  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_role'); // ✨ مسح الـ role عند الخروج
  }

  // 🔍 قراءة البيانات المحفوظة محلياً
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  Future<String?> getUserEmail() async {
    return await secureStorage.read(key: 'user_email');
  }

  Future<String?> getUserName() async {
    return await secureStorage.read(key: 'user_name');
  }

  // ✨ دالة جديدة لقراءة الـ user_role لتحديد الشاشة المناسبة للمستخدم
  Future<String?> getUserRole() async {
    return await secureStorage.read(key: 'user_role');
  }
}