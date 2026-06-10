import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/vehicle_model.dart';

class VehiclesService {
  final Dio _dio = ApiClient().dio;

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _dio.get(
        ApiConstants.vehicles,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List vehiclesList = data is Map<String, dynamic>
            ? data['vehicles'] ?? []
            : data;

        return vehiclesList
            .map((e) => VehicleModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load vehicles';

      throw Exception(
        message ?? 'Failed to load vehicles',
      );
    }
  }

  Future<Map<String, dynamic>> addVehicle({
    required String name,
    required String plateNumber,
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.vehicles,
        data: {
          'name': name,
          'plateNumber': plateNumber,
          'deviceId': deviceId,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to add vehicle';

      throw Exception(
        message ?? 'Failed to add vehicle',
      );
    }
  }
}