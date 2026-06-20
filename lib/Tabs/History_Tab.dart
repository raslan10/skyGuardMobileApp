import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/models/trip_model.dart';
import 'package:skyguardmobileapp/models/accident_model.dart';
import 'package:skyguardmobileapp/services/trips_service.dart';
import 'package:skyguardmobileapp/services/accidents_service.dart';

// 📄 باقات الـ PDF والطباعة
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Advanced Logs & Gamification",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: "Trips History", icon: Icon(Icons.route)),
              Tab(text: "Accident Reports", icon: Icon(Icons.warning_amber_rounded)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TripsTab(),
            AccidentsTab(),
          ],
        ),
      ),
    );
  }
}

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final TripsService tripsService = TripsService();
  bool isLoading = true;
  List<TripModel> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await tripsService.getTrips();
      if (!mounted) return;
      setState(() {
        trips = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.handle(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchTrips,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _gamificationHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Detailed Trips History",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          trips.isEmpty ? _emptyState() : _tripsList(),
        ],
      ),
    );
  }

  Widget _gamificationHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFFE3F2FD), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                "Driver Achievements",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _badgeChip("🥈 Road Guardian", Colors.grey[300]!, Colors.black87, true),
                const SizedBox(width: 8),
                _badgeChip("🥉 Safe Driver", Colors.orange[100]!, Colors.orange[800]!, false),
                const SizedBox(width: 8),
                _badgeChip("🥇 SkyGuard Elite", Colors.amber[50]!, Colors.amber[800]!, false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _badgeChip(String label, Color bgColor, Color textColor, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent ? Border.all(color: const Color(0xFF007BA7), width: 1.5) : null,
      ),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          if (isCurrent) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF007BA7)),
          ]
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.route, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            Text("No trips yet", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _tripsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black12.withValues(alpha: 0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          "Trip #${trip.id}",
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF007BA7))
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.security, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                            "Score: ${trip.safetyScore}/100",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          '${trip.startLocation} → ${trip.endLocation}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tripMetricTile(Icons.straighten, "${trip.distance} km", "Distance"),
                    _tripMetricTile(Icons.access_time, "${trip.duration} min", "Duration"),
                    _tripMetricTile(Icons.phone_android, "${trip.distractionsCount}", "Distractions"),
                    _tripMetricTile(Icons.front_hand, "${trip.harshBrakesCount}", "Harsh Brakes"),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tripMetricTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}

class AccidentsTab extends StatefulWidget {
  const AccidentsTab({super.key});

  @override
  State<AccidentsTab> createState() => _AccidentsTabState();
}

class _AccidentsTabState extends State<AccidentsTab> {
  final AccidentsService accidentsService = AccidentsService();
  bool isLoading = true;
  List<AccidentModel> accidents = [];

  @override
  void initState() {
    super.initState();
    fetchAccidents();
  }

  Future<void> fetchAccidents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await accidentsService.getAccidents();
      if (!mounted) return;
      setState(() {
        accidents = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.handle(e))),
      );
    }
  }

  Future<void> _generateAndPrintPdf(AccidentModel accident) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "SKYGUARD SAFETY SYSTEM",
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "Official Incident & Accident Report",
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700), // ✨ تم إزالة الـ const من هنا
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2, color: PdfColors.red900),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Incident Details:",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 10),
                pw.Text("• Event Type: ${accident.type.toUpperCase()}", style: pw.TextStyle(fontSize: 13)), // ✨ تم إزالة الـ const من هنا
                pw.Text("• Severity Level: ${accident.severity.toUpperCase()}", style: pw.TextStyle(fontSize: 13)), // ✨ تم إزالة الـ const من هنا
                pw.Text("• Timestamp: ${accident.timestamp}", style: pw.TextStyle(fontSize: 13)), // ✨ تم إزالة الـ const من هنا
                pw.Text("• Impact Coordinates: Lat ${accident.latitude} , Lng ${accident.longitude}", style: pw.TextStyle(fontSize: 13)), // ✨ تم إزالة الـ const من هنا
                pw.SizedBox(height: 20),
                pw.Text(
                  "Telemetry & Evidence Analysis:",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 10),
                pw.Text("• G-Force / Acceleration Data Status: Captured & Synced to Postgres DB", style: pw.TextStyle(fontSize: 13)), // ✨ تم إزالة الـ const من هنا
                pw.Text("• Dashcam Status: Pre-Impact Camera Images Securely Saved", style: pw.TextStyle(fontSize: 13)), // ✨ تم إزالة الـ const من هنا
                pw.SizedBox(height: 40),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    "This report is automatically generated by SkyGuard AI Crash Inference Engine.",
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600), // ✨ تم إزالة الـ const من هنا وتعديل الـ FontStyle
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'SkyGuard_Accident_Report_${accident.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchAccidents,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (accidents.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: accidents.length,
      itemBuilder: (context, index) {
        final accident = accidents[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.car_crash, color: Colors.red, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          accident.type,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red[900]),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _generateAndPrintPdf(accident),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 14, color: Colors.red),
                      label: Text("PDF", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                _accidentDetailRow(Icons.g_mobiledata, "G-Force / Acceleration Data Captured", "Telemetry"),
                _accidentDetailRow(Icons.location_on, "${accident.latitude}, ${accident.longitude}", "Impact Location"),
                _accidentDetailRow(Icons.access_time, accident.timestamp, "Time of Accident"),
                _accidentDetailRow(Icons.camera_alt, "Camera Pre-Impact Images Saved", "Evidence"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.gpp_bad, color: Colors.red[700], size: 16),
                      const SizedBox(width: 6),
                      Text("Severity Level: ${accident.severity.toUpperCase()}", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red[700])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _accidentDetailRow(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.car_crash, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            Text("No accidents recorded", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}