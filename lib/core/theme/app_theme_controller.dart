import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeMode themeMode = ThemeMode.light;

  Future<void> loadTheme() async {
    final savedTheme = await _storage.read(key: 'theme_mode');

    if (savedTheme == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (savedTheme == 'system') {
      themeMode = ThemeMode.system;
    } else {
      themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode mode) async {
    themeMode = mode;

    String value = 'light';

    if (mode == ThemeMode.dark) {
      value = 'dark';
    } else if (mode == ThemeMode.system) {
      value = 'system';
    }

    await _storage.write(
      key: 'theme_mode',
      value: value,
    );

    notifyListeners();
  }
}