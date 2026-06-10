import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/emergency_contact.dart';
import '../models/emergency_report.dart';

class EmergencyStorageService {
  static const String contactsKey = 'emergency_contacts';
  static const String reportsKey = 'emergency_reports';

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = contacts.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(contactsKey, encoded);
  }

  Future<List<EmergencyContact>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(contactsKey) ?? [];

    return data.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return EmergencyContact.fromJson(decoded);
    }).toList();
  }

  Future<void> saveReport(EmergencyReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final oldReports = prefs.getStringList(reportsKey) ?? [];
    oldReports.add(jsonEncode(report.toJson()));
    await prefs.setStringList(reportsKey, oldReports);
  }

  Future<List<EmergencyReport>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(reportsKey) ?? [];

    return data.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return EmergencyReport.fromJson(decoded);
    }).toList();
  }
}