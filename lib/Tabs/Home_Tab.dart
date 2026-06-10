import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'History_Tab.dart';
import 'Alert_Tab.dart';
import '../MapScreen/mapsScreen.dart';
import '../media/media_gallery_screen.dart';
import '../support/contact_us_screen.dart';
import '../support/reviews_screen.dart';
import 'package:skyguardmobileapp/models/statistics_model.dart';
import 'package:skyguardmobileapp/services/statistics_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final StatisticsService statisticsService = StatisticsService();

  StatisticsModel? statistics;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

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
      });

      print("UI TOTAL ALERTS: ${result.totalAlerts}");
      print("UI TOTAL ACCIDENTS: ${result.totalAccidents}");
      print("UI FIRE COUNT: ${result.fireCount}");
      print("UI HIGH SEVERITY: ${result.highSeverityCount}");
    } catch (e) {
      print(e);

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
                    _header(),
                    const SizedBox(height: 20),

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
                      "Last Trip",
                      "No trips yet",
                      Icons.route,
                          () {},
                    ),
                    const SizedBox(height: 10),
                    _recentCard(
                      "Last Accident",
                      "No accidents",
                      Icons.car_crash,
                          () {},
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle("Weekly Overview"),
                    const SizedBox(height: 10),
                    _chartPlaceholder(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF007BA7), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SkyGuard",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your safety monitoring dashboard",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryTab()),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertTab()),
                  );
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black12.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF007BA7),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryTab()),
            );
          },
        ),
        _actionChip(
          label: "View Accidents",
          icon: Icons.car_crash,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryTab()),
            );
          },
        ),
        _actionChip(
          label: "View Alerts",
          icon: Icons.notifications,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlertTab()),
            );
          },
        ),
        _actionChip(
          label: "Media Gallery",
          icon: Icons.perm_media,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MediaGalleryScreen(),
              ),
            );
          },
        ),
        _actionChip(
          label: "Contact Us",
          icon: Icons.contact_mail,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ContactUsScreen(),
              ),
            );
          },
        ),
        _actionChip(
          label: "Reviews",
          icon: Icons.rate_review,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReviewsScreen(),
              ),
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
          label: "Vehicles",
          icon: Icons.directions_car,
          onTap: () {
            Navigator.pushNamed(context, '/vehicles');
          },
        ),
        _actionChip(
          label: "Emergency Contacts",
          icon: Icons.contact_phone,
          onTap: () {
            Navigator.pushNamed(context, '/emergencyContacts');
          },
        ),
        _actionChip(
          label: "Emergency Reports",
          icon: Icons.warning_amber_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/emergencyReports');
          },
        ),
      ],
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF007BA7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentCard(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      ) {
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
              color: Colors.black.withOpacity(0.05),
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
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _chartPlaceholder() {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "Chart Placeholder\n(Will be connected to backend later)",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}