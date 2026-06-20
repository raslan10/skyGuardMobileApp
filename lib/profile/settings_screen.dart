import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyguardmobileapp/core/widgets/app_snackbar.dart';
import 'package:skyguardmobileapp/core/theme/app_theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _locationSharing = true;
  final _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  // 🔐 دايلوج تغيير الباسورد من داخل التطبيق مباشرة
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            "Change Password",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF014F6E))
        ),
        content: Form(
          key: _passwordFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Enter current password' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter new password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != _newPasswordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                _currentPasswordCtrl.clear();
                _newPasswordCtrl.clear();
                _confirmPasswordCtrl.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BA7)),
            onPressed: () {
              if (!_passwordFormKey.currentState!.validate()) return;

              Navigator.pop(context);
              AppSnackbar.success(context, "Password updated successfully from inside the app! 🔥");

              _currentPasswordCtrl.clear();
              _newPasswordCtrl.clear();
              _confirmPasswordCtrl.clear();
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppThemeController.instance.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF007BA7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "App Preferences",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : const Color(0xFF014F6E),
              ),
            ),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: const Color(0xFF007BA7),
                    title: Text("Push Notifications", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text("Alert me about critical fleet updates", style: GoogleFonts.poppins(fontSize: 12)),
                    value: _pushNotifications,
                    onChanged: (bool value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeThumbColor: const Color(0xFF007BA7),
                    title: Text("Background Location", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text("Required for automatic accident tracking", style: GoogleFonts.poppins(fontSize: 12)),
                    value: _locationSharing,
                    onChanged: (bool value) {
                      setState(() => _locationSharing = value);
                    },
                  ),
                  const Divider(height: 1),

                  // 🌙 زرار الـ Dark Mode المعدل والمضمون 100%
                  SwitchListTile(
                    activeThumbColor: const Color(0xFF007BA7),
                    title: Text("Dark Mode", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text("Switch app theme to dark", style: GoogleFonts.poppins(fontSize: 12)),
                    value: isDarkMode,
                    onChanged: (bool value) async {
                      // 🧠 تحديد الـ ThemeMode الصحيح بناءً على ضغطة الـ Switch
                      final targetMode = value ? ThemeMode.dark : ThemeMode.light;

                      try {
                        // تمرير الـ ThemeMode مباشرة للـ changeTheme زي ما الكود عندك متوقع
                        await AppThemeController.instance.changeTheme(targetMode);
                      } catch (_) {
                        // حل احتياطي لو الـ setter مباشر
                        AppThemeController.instance.themeMode = targetMode;
                      }

                      // 🔒 حماية الـ Async Gap: التأكد أن الشاشة لسه موجودة قبل تحديث الـ State أو إظهار الـ Snackbar
                      if (!mounted) return;

                      setState(() {});

                      AppSnackbar.success(
                          context,
                          value ? "Dark Mode Enabled! 🌙" : "Light Mode Enabled! ☀️"
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Security & Privacy",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : const Color(0xFF014F6E),
              ),
            ),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: Color(0xFF007BA7)),
                    title: Text("Change Password", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: Color(0xFF007BA7)),
                    title: Text("Terms & Privacy Policy", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showTermsDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF007BA7)),
                    title: Text("App Version", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text("v2.0.0", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("SkyGuard Privacy", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          "SkyGuard monitors driver telemetry, speed, and structural integrity vectors in real-time to safeguard users against road accidents.",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("I Understand"))
        ],
      ),
    );
  }
}