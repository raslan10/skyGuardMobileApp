import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/profile_model.dart';

class ProfileService {
  final Dio _dio = ApiClient().dio;

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get(
        ApiConstants.profile,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          return ProfileModel.fromJson(data['user']);
        } else {
          throw Exception(
            data['message'] ?? 'Failed to load profile',
          );
        }
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to load profile';

      throw Exception(message);
    }
  }
}