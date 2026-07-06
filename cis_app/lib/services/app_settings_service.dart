import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static final ValueNotifier<bool> notificationsEnabled = ValueNotifier(true);
  static final ValueNotifier<String> language = ValueNotifier('English');

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode') ?? 'light';
    final savedNotifications = prefs.getBool('notifications_enabled') ?? true;
    final savedLanguage = prefs.getString('language') ?? 'English';

    themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notificationsEnabled.value = savedNotifications;
    language.value = savedLanguage;
  }

  static Future<void> setThemeMode(ThemeMode value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', value == ThemeMode.dark ? 'dark' : 'light');
    themeMode.value = value;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notificationsEnabled.value = value;
  }

  static Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    language.value = value;
  }
}
