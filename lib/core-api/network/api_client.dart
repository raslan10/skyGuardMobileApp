import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late Dio dio;

  final FlutterSecureStorage secureStorage =
  const FlutterSecureStorage();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
          await secureStorage.read(key: 'token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
            'Bearer $token';
          }

          print('REQUEST: ${options.method} ${options.uri}');
          print('HEADERS: ${options.headers}');
          print('DATA: ${options.data}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE: ${response.statusCode}');
          print('BODY: ${response.data}');

          handler.next(response);
        },
        onError: (error, handler) async {
          print('API ERROR TYPE: ${error.type}');
          print('API ERROR MESSAGE: ${error.message}');
          print('API ERROR ERROR: ${error.error}');
          print('STATUS: ${error.response?.statusCode}');
          print('BODY: ${error.response?.data}');

          if (error.response?.statusCode == 401) {
            await secureStorage.delete(key: 'token');
            await secureStorage.delete(key: 'user_email');
            await secureStorage.delete(key: 'user_name');

            print('TOKEN EXPIRED - USER LOGGED OUT LOCALLY');
          }

          handler.next(error);
        },
      ),
    );
  }
}