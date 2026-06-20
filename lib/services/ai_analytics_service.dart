import 'dart:convert';
import 'package:http/http.dart' as http;

class AiAnalyticsService {
  // استخدام المضيف المحلي للباك آند (لو شغال على محاكي أندرويد استبدل localhost بـ 10.0.2.2)
  final String baseUrl = "http://localhost:5000/api/v1";

  Future<Map<String, dynamic>> getAnalyticsByReportId(String reportId) async {
    final url = Uri.parse('$baseUrl/emergency/reports/$reportId/ai-analytics');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Server returned error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to connect to AI Analytics Server: $e");
    }
  }
}