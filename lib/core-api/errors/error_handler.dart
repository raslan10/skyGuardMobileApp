import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;

        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }

        if (data is String && data.isNotEmpty) {
          return data;
        }

        switch (error.response?.statusCode) {
          case 400:
            return 'Bad request';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access denied';
          case 404:
            return 'Data not found';
          case 500:
            return 'Server error. Try again later.';
          default:
            return 'Something went wrong';
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout';
        case DioExceptionType.sendTimeout:
          return 'Send timeout';
        case DioExceptionType.connectionError:
          return 'No internet connection';
        default:
          return 'Something went wrong';
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}