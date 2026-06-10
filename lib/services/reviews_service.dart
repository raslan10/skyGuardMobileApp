import 'package:dio/dio.dart';
import 'package:skyguardmobileapp/core-api/network/api_client.dart';
import 'package:skyguardmobileapp/core-api/network/api_constants.dart';
import 'package:skyguardmobileapp/models/review_model.dart';

class ReviewsService {
  final Dio _dio = ApiClient().dio;

  Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await _dio.get(
        ApiConstants.reviews,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List reviewsList =
        data is Map<String, dynamic>
            ? data['reviews'] ?? []
            : data;

        return reviewsList
            .map((e) => ReviewModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to load reviews';

      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> submitReview({
    required String name,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.reviews,
        data: {
          'name': name,
          'rating': rating,
          'comment': comment,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data.toString() ??
          'Failed to submit review';

      throw Exception(message);
    }
  }
}