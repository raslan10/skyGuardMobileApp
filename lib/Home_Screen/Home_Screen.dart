import 'package:flutter/material.dart';
import 'package:skyguardmobileapp/MapScreen/appbar.dart';
import 'package:skyguardmobileapp/Tabs/Alert_Tab.dart';
import 'package:skyguardmobileapp/Tabs/History_Tab.dart';
import 'package:skyguardmobileapp/Tabs/Home_Tab.dart';
import 'package:skyguardmobileapp/Tabs/Proofile_Tab.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/core/resources/reusable/AssetsManager.dart';
import 'package:skyguardmobileapp/core/resources/reusable/StringsManager.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/emergency/models/emergency_report.dart';
import 'package:skyguardmobileapp/emergency/services/emergency_storage_service.dart';
import 'package:skyguardmobileapp/emergency/services/location_service.dart';
import 'package:skyguardmobileapp/emergency/widgets/sos_countdown_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/services/sos_service.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> tabs = [
    const HomeTab(),
    const AlertTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  void handleSOS(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return SosCountdownDialog(
          onCancel: () {
            Navigator.pop(context);
          },
          onConfirm: () async {
            Navigator.pop(context);

            try {
              final locationService =
              LocationService();

              final storageService =
              EmergencyStorageService();

              final sosService =
              SosService();

              final position =
              await locationService
                  .getCurrentLocation();

              final latitude =
                  position?.latitude ??
                      30.0444;

              final longitude =
                  position?.longitude ??
                      31.2357;

              final sosResult =
              await sosService.sendSos(
                email: 'test@gmail.com',
                latitude: latitude,
                longitude: longitude,
                message:
                'Emergency SOS request',
              );

              if (sosResult['success'] !=
                  true) {
                throw Exception(
                  sosResult['message'] ??
                      'Failed to send SOS',
                );
              }

              final report = EmergencyReport(
                id: 0,
                triggerType: 'manual_sos',
                timestamp: DateTime.now(),
                status: 'sent',
                note: sosResult['message'] ?? 'User triggered SOS manually',
                latitude: latitude,
                longitude: longitude,
              );

              await storageService
                  .saveReport(report);

              final contacts =
              await storageService
                  .getContacts();

              if (!mounted) return;

              if (contacts.isEmpty) {
                AppSnackbar.info(
                  context,
                  sosResult['message'] ??
                      'Emergency report sent, but no emergency contacts found',
                );

                return;
              }

              AppSnackbar.success(
                context,
                'Emergency report sent to ${contacts.length} contact(s)',
              );

              for (final contact
              in contacts) {
                await Future.delayed(
                  const Duration(
                    milliseconds: 800,
                  ),
                );

                if (!mounted) return;

                AppSnackbar.info(
                  context,
                  'Sending alert to ${contact.name}',
                );
              }
            } catch (e) {
              if (!mounted) return;

              AppSnackbar.error(
                context,
                ErrorHandler.handle(e),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const WaveAppBar(),
      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: Colors.red,
        elevation: 8,
        onPressed: () =>
            handleSOS(context),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
        ),
        label: Text(
          "SOS",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight:
            FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius:
          const BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected:
              (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          height: 74,
          backgroundColor:
          Colors.transparent,
          indicatorColor:
          const Color(0xFFE3F2FD),
          labelTextStyle:
          WidgetStateProperty.all(
            GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
              FontWeight.w500,
            ),
          ),
          destinations: [
            _buildNavItem(
              AssetsManager.home,
              StringsManager.home,
              0,
            ),
            _buildNavItem(
              AssetsManager.alert,
              StringsManager.alert,
              1,
            ),
            _buildNavItem(
              AssetsManager.history,
              StringsManager.history,
              2,
            ),
            _buildNavItem(
              AssetsManager.profile,
              StringsManager.profile,
              3,
            ),
          ],
        ),
      ),
      body: tabs[selectedIndex],
    );
  }

  NavigationDestination _buildNavItem(
      String iconPath,
      String label,
      int index,
      ) {
    final bool isSelected =
        selectedIndex == index;

    return NavigationDestination(
      icon: Container(
        padding: EdgeInsets.all(
          isSelected ? 10 : 0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(
              0xFF007BA7)
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
        child: Image.asset(
          iconPath,
          width: isSelected
              ? 20
              : 26,
          height: isSelected
              ? 20
              : 26,
          color: isSelected
              ? Colors.white
              : const Color(
              0xFF007BA7),
        ),
      ),
      label: label,
    );
  }
}