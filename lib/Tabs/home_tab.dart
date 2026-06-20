import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_tab.dart';
import 'Alert_Tab.dart';
import '../MapScreen/mapsScreen.dart';
import 'package:skyguardmobileapp/media/media_gallery_screen.dart';
import 'package:skyguardmobileapp/vehicles_screen/vehicles_screen.dart';
import 'package:skyguardmobileapp/models/statistics_model.dart';
import 'package:skyguardmobileapp/services/statistics_service.dart';
import 'package:skyguardmobileapp/tabs/ai_analytics_tab.dart';
import 'package:skyguardmobileapp/emergency/screens/emergency_reports_screen.dart';
import 'package:skyguardmobileapp/media/ai_prediction_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final StatisticsService statisticsService = StatisticsService();
  StatisticsModel? statistics;
  bool isLoadingStats = true;

  int safetyScore = 100;
  String driverRank = "Excellent";
  Color rankColor = Colors.green;
  double drivingHoursToday = 0.0;
  String weeklyTrend = "+0.0%";
  String lastAlertText = "No recent dangerous events";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final result = await statisticsService.getStatistics();
      if (!mounted) return;

      setState(() {
        statistics = result;
        isLoadingStats = false;

        safetyScore = result.safetyScore;
        driverRank = result.driverRank;
        drivingHoursToday = result.drivingHoursToday;
        weeklyTrend = result.weeklyTrend;

        if (driverRank.toLowerCase() == "excellent") {
          rankColor = Colors.green;
        } else if (driverRank.toLowerCase() == "good") {
          rankColor = Colors.orange;
        } else {
          rankColor = Colors.red;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: fetchStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerWithSafetyScore(),
                    const SizedBox(height: 20),
                    _sectionTitle("Smart Vehicle Monitoring"),
                    const SizedBox(height: 10),
                    _smartVehicleMonitoringCard(),
                    const SizedBox(height: 24),
                    _sectionTitle("Overview"),
                    const SizedBox(height: 10),
                    _kpiRow(context),
                    const SizedBox(height: 24),
                    _sectionTitle("Quick Actions"),
                    const SizedBox(height: 10),
                    _quickActions(context),
                    const SizedBox(height: 24),
                    _sectionTitle("Recent Activity"),
                    const SizedBox(height: 10),

                    _recentCard(
                      "Last Trip Summary",
                      isLoadingStats
                          ? "Loading last trip..."
                          : "Distance: 120.5 km | Duration: 60 min | Score: $safetyScore/100",
                      Icons.route,
                          () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryTab()));
                      },
                    ),
                    const SizedBox(height: 10),
                    _recentCard(
                      "Last Emergency Alert",
                      isLoadingStats ? "..." : lastAlertText,
                      Icons.warning_amber_rounded,
                          () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertTab()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerWithSafetyScore() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF007BA7), Color(0xFF014F6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12), // ✅ تم استخدام withValues
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SkyGuard Elite",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "AI Safety Driving System",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2), // ✅ تم التحديث لـ withValues
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: rankColor, width: 1.5),
                ),
                child: Text(
                  driverRank,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _safetyCircularScore(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _safetyMiniDetail(Icons.access_time, "$drivingHoursToday hrs", "Driving Today"),
                  const SizedBox(height: 12),
                  _safetyMiniDetail(Icons.trending_up, "$weeklyTrend Improved", "Weekly Trend"),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _safetyCircularScore() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 85,
          height: 85,
          child: CircularProgressIndicator(
            value: safetyScore / 100,
            strokeWidth: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(safetyScore > 75 ? Colors.greenAccent : Colors.orangeAccent),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$safetyScore",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Safety Score",
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: Colors.white60,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _safetyMiniDetail(IconData icon, String mainText, String subText) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainText,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              subText,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
            ),
          ],
        )
      ],
    );
  }

  Widget _smartVehicleMonitoringCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // ✅ تم التحديث لـ withValues
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12.withValues(alpha: 0.05)), // ✅ تم التحديث لـ withValues
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, color: Color(0xFF007BA7)),
                  const SizedBox(width: 8),
                  Text(
                    "Live Speedometer",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                    const SizedBox(width: 4),
                    Text("Engine OK", style: GoogleFonts.poppins(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "75",
                    style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF007BA7)),
                  ),
                  Text("km/h", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 40, child: VerticalDivider(color: Colors.black12)),
              _vehicleStatTile(Icons.local_gas_station, "Fuel Level", "78%"),
              const SizedBox(height: 40, child: VerticalDivider(color: Colors.black12)),
              _vehicleStatTile(Icons.trending_down, "Harsh Brake", "0 Event"),
            ],
          )
        ],
      ),
    );
  }

  Widget _vehicleStatTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _kpiRow(BuildContext context) {
    final totalAlerts = statistics?.totalAlerts ?? 0;
    final totalAccidents = statistics?.totalAccidents ?? 0;
    final fireCount = statistics?.fireCount ?? 0;
    final highSeverity = statistics?.highSeverityCount ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                title: "Fire",
                value: isLoadingStats ? "..." : fireCount.toString(),
                icon: Icons.local_fire_department,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kpiCard(
                title: "Accidents",
                value: isLoadingStats ? "..." : totalAccidents.toString(),
                icon: Icons.car_crash,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryTab()));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                title: "Alerts",
                value: isLoadingStats ? "..." : totalAlerts.toString(),
                icon: Icons.notifications_active,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertTab()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kpiCard(
                title: "High Severity",
                value: isLoadingStats ? "..." : highSeverity.toString(),
                icon: Icons.shield,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // ✅ تم التحديث لـ withValues
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black12.withValues(alpha: 0.04)), // ✅ تم التحديث لـ withValues
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF007BA7), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _actionChip(
          label: "View Trips",
          icon: Icons.route,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryTab()));
          },
        ),
        _actionChip(
          label: "My Vehicles",
          icon: Icons.directions_car_filled_outlined,
          onTap: () {
            Navigator.pushNamed(context, VehiclesScreen.routeName);
          },
        ),
        _actionChip(
          label: "Media Gallery",
          icon: Icons.perm_media,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaGalleryScreen()));
          },
        ),
        _actionChip(
          label: "AI Analytics",
          icon: Icons.analytics_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: SafeArea(
                    child: AIPredictionScreen(reportId: "default_event"),
                  ),
                ),
              ),
            );
          },
        ),
        _actionChip(
          label: "SOS Reports",
          icon: Icons.emergency_share,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyReportsScreen()),
            );
          },
        ),
        _actionChip(
          label: "Open Map",
          icon: Icons.map,
          onTap: () {
            Navigator.pushNamed(context, MapsScreen.routeName);
          },
        ),
        _actionChip(
          label: "Family Tracking",
          icon: Icons.family_restroom,
          onTap: () {
            Navigator.pushNamed(context, MapsScreen.routeName);
          },
        ),
      ],
    );
  }

  Widget _actionChip({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // ✅ تم التحديث لـ withValues
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF007BA7)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _recentCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // ✅ تم التحديث لـ withValues
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF007BA7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}