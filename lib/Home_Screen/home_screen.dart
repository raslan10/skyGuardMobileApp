import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/MapScreen/appbar.dart';

// 🔄 الـ Relative Imports المضمونة
import '../Tabs/Alert_Tab.dart';
import '../Tabs/history_tab.dart';
import '../Tabs/home_tab.dart';
import '../tabs/Proofile_Tab.dart';
import '../tabs/admin_dashboard_tab.dart'; // 🔥 Import لوحة تحكم الأدمن الجديدة

import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core/resources/reusable/AssetsManager.dart';
import 'package:skyguardmobileapp/core/resources/reusable/StringsManager.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/emergency/models/emergency_report.dart';
import 'package:skyguardmobileapp/emergency/services/emergency_storage_service.dart';
import 'package:skyguardmobileapp/emergency/services/location_service.dart';
import 'package:skyguardmobileapp/emergency/widgets/sos_countdown_dialog.dart';
import 'package:skyguardmobileapp/services/sos_service.dart';
import 'package:skyguardmobileapp/services/auth_service.dart'; // 🔥 Import لـ قراءة الـ Role

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  String currentRole = "user"; // ✨ افتراضي سائق لحين القراءة من الكاش
  bool isRoleLoading = true;

  final AuthService _authService = AuthService();

  // 📝 قائمة تابس السائق (User)
  final List<Widget> userTabs = [
    const HomeTab(),
    const AlertTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  // 🛠️ قائمة تابس المشرف (Admin)
  final List<Widget> adminTabs = [
    const AdminDashboardTab(), // لوحة التحكم الشاملة للأسطول
    const ProfileTab(),        // الملف الشخصي للأدمن
  ];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // 🧠 دالة فحص الصلاحية لتغيير واجهة التطبيق ديناميكياً
  Future<void> _checkUserRole() async {
    try {
      final role = await _authService.getUserRole();
      if (!mounted) return;
      setState(() {
        currentRole = role ?? "user";
        isRoleLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isRoleLoading = false);
    }
  }

  void handleSOS(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final localContext = context;

    showDialog(
      context: localContext,
      barrierDismissible: false,
      builder: (_) {
        return SosCountdownDialog(
          onCancel: () => Navigator.pop(localContext),
          onConfirm: () async {
            final navigator = Navigator.of(localContext);
            navigator.pop();

            try {
              final locationService = LocationService();
              final storageService = EmergencyStorageService();
              final sosService = SosService();

              final position = await locationService.getCurrentLocation();
              final latitude = position?.latitude ?? 30.0444;
              final longitude = position?.longitude ?? 31.2357;

              final double currentSpeedInKmH = ((position?.speed ?? 0) * 3.6);
              final String currentTime = DateTime.now().toIso8601String();
              final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

              final contacts = await storageService.getContacts();

              if (contacts.isEmpty) {
                if (!mounted) return;
                AppSnackbar.info(localContext, 'No family contacts found. Sending to main emergency center...');

                final sosResult = await sosService.sendSos(
                  email: 'emergency-center@skyguard.com',
                  latitude: latitude,
                  longitude: longitude,
                  message: 'CRITICAL: Automatic Accident/SOS Report triggered.',
                  speed: currentSpeedInKmH,
                  accidentTime: currentTime,
                  mapLink: googleMapsUrl,
                );

                if (sosResult['success'] != true) {
                  throw Exception(sosResult['message'] ?? 'Failed to send SOS');
                }

                if (!mounted) return;
                AppSnackbar.success(localContext, 'Emergency report sent to main center successfully!');
              } else {
                if (!mounted) return;
                AppSnackbar.info(localContext, 'Sending emergency reports to family contacts...');

                for (final contact in contacts) {
                  await sosService.sendSos(
                    email: 'family_alert@skyguard.com',
                    latitude: latitude,
                    longitude: longitude,
                    message: 'ALERT! Emergency SOS triggered for driver. Phone: ${contact.phone}. Assistance required.',
                    speed: currentSpeedInKmH,
                    accidentTime: currentTime,
                    mapLink: googleMapsUrl,
                  );
                  await Future.delayed(const Duration(milliseconds: 300));
                }
              }

              final report = EmergencyReport(
                id: 0,
                triggerType: 'manual_sos',
                timestamp: DateTime.now(),
                status: 'sent',
                note: contacts.isEmpty
                    ? 'SOS sent to central emergency station.'
                    : 'SOS broadcasted to all registered family contacts.',
                latitude: latitude,
                longitude: longitude,
              );

              await storageService.saveReport(report);

              if (!mounted) return;
              if (contacts.isNotEmpty) {
                AppSnackbar.success(localContext, 'Emergency Broadcast sent to all ${contacts.length} family members!');
              }
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text(ErrorHandler.handle(e))),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // شاشة تحميل سريعة حتى يتم تحديد الـ Role ومنع الـ Glitches
    if (isRoleLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isAdmin = currentRole == "admin";
    final activeTabs = isAdmin ? adminTabs : userTabs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const WaveAppBar(),

      // 🚨 إظهار زرار الـ SOS للسائقين فقط وإخفائه تماماً لو الحساب المشرف (Admin)
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton.extended(
        backgroundColor: Colors.red,
        elevation: 8,
        onPressed: () => handleSOS(context),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: Text(
          "SOS",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          height: 74,
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFFE3F2FD),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),

          // 🔥 تحديد الـ Navigation Items ديناميكياً بناءً على نوع الصلاحية
          destinations: isAdmin
              ? [
            _buildNavItem(AssetsManager.home, "Control Panel", 0),
            _buildNavItem(AssetsManager.profile, "Profile", 1),
          ]
              : [
            _buildNavItem(AssetsManager.home, StringsManager.home, 0),
            _buildNavItem(AssetsManager.alert, StringsManager.alert, 1),
            _buildNavItem(AssetsManager.history, StringsManager.history, 2),
            _buildNavItem(AssetsManager.profile, StringsManager.profile, 3),
          ],
        ),
      ),
      body: activeTabs[selectedIndex],
    );
  }

  NavigationDestination _buildNavItem(String iconPath, String label, int index) {
    final bool isSelected = selectedIndex == index;
    return NavigationDestination(
      icon: Container(
        padding: EdgeInsets.all(isSelected ? 10 : 0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007BA7) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          iconPath,
          width: isSelected ? 20 : 26,
          height: isSelected ? 20 : 26,
          color: isSelected ? Colors.white : const Color(0xFF007BA7),
        ),
      ),
      label: label,
    );
  }
}