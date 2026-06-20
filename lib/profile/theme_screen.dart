import 'package:flutter/material.dart';
import 'package:skyguardmobileapp/core/theme/app_theme_controller.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = AppThemeController.instance.themeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _themeTile(
            context: context,
            title: 'Light Mode',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            currentMode: currentTheme,
          ),
          _themeTile(
            context: context,
            title: 'Dark Mode',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            currentMode: currentTheme,
          ),
          _themeTile(
            context: context,
            title: 'System Default',
            icon: Icons.phone_android,
            mode: ThemeMode.system,
            currentMode: currentTheme,
          ),
        ],
      ),
    );
  }

  Widget _themeTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: currentMode == mode
            ? const Icon(Icons.check, color: Color(0xFF007BA7))
            : null,
        onTap: () async {
          await AppThemeController.instance.changeTheme(mode);

          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}