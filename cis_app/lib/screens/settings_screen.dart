import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/app_settings_service.dart';
import '../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0+1';

  Future<void> _logout(BuildContext context) async {
    await ApiService.clearToken();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.selectLoginMethod, (route) => false);
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('App Preferences', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppSettingsService.themeMode,
            builder: (context, themeMode, _) => Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.dark_mode_rounded),
                title: const Text('Dark Theme'),
                subtitle: Text(themeMode == ThemeMode.dark ? 'Dark mode enabled' : 'Light mode enabled'),
                value: themeMode == ThemeMode.dark,
                onChanged: (value) => AppSettingsService.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: AppSettingsService.language,
            builder: (context, language, _) => Card(
              child: ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Language'),
                subtitle: Text(language),
                trailing: DropdownButton<String>(
                  value: language,
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: 'Sinhala', child: Text('Sinhala')),
                  ],
                  onChanged: (value) {
                    if (value != null) AppSettingsService.setLanguage(value);
                  },
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AppSettingsService.notificationsEnabled,
            builder: (context, enabled, _) => Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications_active_rounded),
                title: const Text('Notification Settings'),
                subtitle: Text(enabled ? 'Notifications enabled' : 'Notifications disabled'),
                value: enabled,
                onChanged: AppSettingsService.setNotificationsEnabled,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('App Version'),
              subtitle: const Text(appVersion),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.apartment_rounded),
              title: const Text('About Data Nexus'),
              subtitle: const Text('Central Information System for clients and organizations'),
              onTap: () => _showInfo(
                context,
                'About Data Nexus',
                'Data Nexus helps clients discover organization services while allowing organizations to create business servers and request verification.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_rounded),
              title: const Text('Contact Support'),
              subtitle: const Text('data.nexus.support@example.com'),
              onTap: () => _showInfo(
                context,
                'Contact Support',
                'For project demo support, contact the Data Nexus developer/admin team. ',
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
