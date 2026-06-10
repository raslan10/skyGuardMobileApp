import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/trip_model.dart';

class TripsService {
  final Dio _dio = ApiClient().dio;

  Future<List<TripModel>> getTrips() async {
    try {
      final response = await _dio.get(
        ApiConstants.trips,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List tripsList = (data['history'] ?? [])
            .where((e) => e['type'] == 'trip')
            .toList();

        return tripsList
            .map((e) => TripModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load trips');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load trips';

      throw Exception(
        message ?? 'Failed to load trips',
      );
    }
  }
}