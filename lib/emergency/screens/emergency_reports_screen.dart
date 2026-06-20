import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/emergency_report.dart';
import '../services/emergency_reports_service.dart';
import '../../MapScreen/mapsScreen.dart'; // تأكد من مسار الـ MapsScreen الصحيح عندك

class EmergencyReportsScreen extends StatefulWidget {
  static const String routeName = "emergencyReports";

  const EmergencyReportsScreen({super.key});

  @override
  State<EmergencyReportsScreen> createState() => _EmergencyReportsScreenState();
}

class _EmergencyReportsScreenState extends State<EmergencyReportsScreen> {
  final EmergencyReportsService _service = EmergencyReportsService();

  List<EmergencyReport> reports = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await _service.getReports();

      if (!mounted) return;
      setState(() {
        reports = data.reversed.toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}  '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // دالة ذكية لتحديد لون الشارة بناءً على حالة البلاغ القادمة من السيرفر
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dispatched':
      case 'pending':
        return Colors.red;
      case 'resolved':
      case 'completed':
        return Colors.green;
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SOS Emergency Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFD32F2F), // أحمر طوارئ احترافي
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
      )
          : error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error!,
            textAlign: TextAlign.center, // ✨ تم تعديلها هنا إلى TextAlign.center لتصحيح الإيرور
            style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w500),
          ),
        ),
      )
          : reports.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gpp_good_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No emergency reports yet',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: loadReports,
        color: const Color(0xFFD32F2F),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final statusColor = _getStatusColor(report.status);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(color: Colors.red.withValues(alpha: 0.15), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🚨 الـ Header الخاص بالكارت (نوع المشغل وحالة البلاغ ديناميكياً)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.red.withValues(alpha: 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emergency, color: Color(0xFFD32F2F), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                report.triggerType.toUpperCase(),
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              report.status.toUpperCase(),
                              style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          )
                        ],
                      ),
                    ),

                    // 📝 تفاصيل البلاغ الحقيقية من الموديل
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildReportDetailRow(Icons.access_time, "Dispatch Timestamp", formatDate(report.timestamp)),
                          _buildReportDetailRow(Icons.description_outlined, "Incident Note", report.note.isNotEmpty ? report.note : "No extra notes provided"),
                          _buildReportDetailRow(
                              Icons.location_on_outlined,
                              "GPS Coordinates",
                              report.latitude != null && report.longitude != null
                                  ? "${report.latitude}, ${report.longitude}"
                                  : "Coordinates N/A"
                          ),
                        ],
                      ),
                    ),

                    // 🗺️ زر تتبع الحادثة حقيقياً على الخريطة لو الإحداثيات متوفرة
                    if (report.latitude != null && report.longitude != null)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          onPressed: () {
                            // 🔄 انتقال ذكي لشاشة الخريطة مع تمرير إحداثيات الحادثة الحقيقية
                            Navigator.pushNamed(
                                context,
                                MapsScreen.routeName,
                                arguments: {
                                  'lat': report.latitude,
                                  'lng': report.longitude,
                                  'title': report.triggerType
                                }
                            );
                          },
                          icon: const Icon(Icons.map, color: Colors.white, size: 18),
                          label: Text(
                            "Track Accident Location",
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}