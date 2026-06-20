import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/alerts/alert_details_screen.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/models/alert_model.dart';
import 'package:skyguardmobileapp/services/alert_service.dart';

class AlertTab extends StatefulWidget {
  const AlertTab({super.key});

  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends State<AlertTab> {
  final AlertService alertService = AlertService();

  bool isLoading = true;
  List<AlertModel> alerts = [];

  int attentionScore = 88;
  int fatigueCount = 0;
  int distractionCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await alertService.getAlerts();

      if (!mounted) return;

      setState(() {
        alerts = result;

        fatigueCount = result.where((a) =>
        a.type.toLowerCase().contains('drowsy') ||
            a.type.toLowerCase().contains('yawn') ||
            a.type.toLowerCase().contains('fatigue')
        ).length;

        distractionCount = result.where((a) =>
        a.type.toLowerCase().contains('phone') ||
            a.type.toLowerCase().contains('distract') ||
            a.type.toLowerCase().contains('look away')
        ).length;

        int totalDeductions = (fatigueCount * 8) + (distractionCount * 6);
        attentionScore = (100 - totalDeductions).clamp(30, 100);
        isLoading = false; // تحديث الحالة هنا بدلاً من الـ finally لمنع إيرور الـ return
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AI Driver Monitoring",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: fetchAlerts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _attentionScoreHeader(),
          const SizedBox(height: 16),
          _aiCategoryStats(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Real-Time Live Logs",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          alerts.isEmpty ? _emptyState() : _alertsList(context),
        ],
      ),
    );
  }

  Widget _attentionScoreHeader() {
    Color scoreColor = attentionScore >= 80 ? Colors.green : (attentionScore >= 60 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: scoreColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: CircularProgressIndicator(
                  value: attentionScore / 100,
                  strokeWidth: 7,
                  backgroundColor: scoreColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Text(
                "$attentionScore%",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: scoreColor),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Driver Attention Score",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  attentionScore >= 80
                      ? "Safe & Focused. Keep it up!"
                      : (attentionScore >= 60 ? "Caution: Distraction detected." : "DANGER! Fatigue levels are high."),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiCategoryStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _aiStatCard(
              title: "Fatigue Events",
              subtitle: "Drowsy / Yawning",
              count: fatigueCount,
              icon: Icons.face_retouching_natural,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _aiStatCard(
              title: "Distractions",
              subtitle: "Phone / Looking Away",
              count: distractionCount,
              icon: Icons.phonelink_erase,
              color: Colors.amber[700]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiStatCard({
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                "$count",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.verified_user, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              "No Dangerous Events Detected",
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              "AI camera stream is clean. السائق منتبه تماماً بالطريق.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        bool isHighSeverity = alert.severity.toLowerCase() == 'high' || alert.severity.toLowerCase() == 'critical';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black12.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isHighSeverity ? Colors.red[50] : Colors.amber[50],
              child: Icon(
                isHighSeverity ? Icons.warning_amber_rounded : Icons.info_outline,
                color: isHighSeverity ? Colors.red : Colors.amber[800],
              ),
            ),
            title: Text(
              alert.type,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Severity: ${alert.severity}  |  ${alert.timestamp}',
              style: GoogleFonts.poppins(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertDetailsScreen(alert: alert),
                ),
              );
            },
          ),
        );
      },
    );
  }
}