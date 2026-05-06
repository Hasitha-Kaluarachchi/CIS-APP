import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const CISApp());
}

class CISApp extends StatelessWidget {
  const CISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIS App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.selectLoginMethod,
      routes: AppRoutes.routes,
    );
  }
}
