import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/accident_model.dart';

class AccidentsService {
  final Dio _dio = ApiClient().dio;

  Future<List<AccidentModel>> getAccidents() async {
    try {
      final response = await _dio.get(
        ApiConstants.accidents,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List accidentsList = (data['history'] ?? [])
            .where((e) => e['type'] == 'accident')
            .toList();

        return accidentsList
            .map((e) => AccidentModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load accidents');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load accidents';

      throw Exception(
        message ?? 'Failed to load accidents',
      );
    }
  }
}