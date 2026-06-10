import 'package:dio/dio.dart';

import '../../core-api/network/api_client.dart';
import '../models/emergency_contact.dart';

class EmergencyContactsService {
  final Dio _dio = ApiClient().dio;

  Future<List<EmergencyContact>> getContacts() async {
    try {
      final response = await _dio.get(
        '/emergency-contacts',
      );

      if (response.statusCode == 200) {
        final List data = response.data['contacts'];

        return data
            .map((e) => EmergencyContact.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load contacts');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data.toString() ??
              'Failed to load contacts';

      throw Exception(message);
    }
  }

  Future<void> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    try {
      final response = await _dio.post(
        '/emergency-contacts',
        data: {
          'name': name,
          'phone': phone,
          'relation': relation,
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception('Failed to add contact');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data.toString() ??
              'Failed to add contact';

      throw Exception(message);
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      final response = await _dio.delete(
        '/emergency-contacts/$id',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete contact');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data.toString() ??
              'Failed to delete contact';

      throw Exception(message);
    }
  }
}