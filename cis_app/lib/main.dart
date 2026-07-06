import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'services/app_settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsService.load();
  runApp(const CISApp());
}

class CISApp extends StatelessWidget {
  const CISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettingsService.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Data Nexus',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF004D48),
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF004D48),
              foregroundColor: Colors.white,
              centerTitle: false,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF00A896),
          ),
        );
      },
    );
  }
}
