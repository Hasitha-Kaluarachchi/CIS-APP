import 'package:flutter/material.dart';

import '../screens/select_login_method_screen.dart';
import '../screens/client_login_screen.dart';
import '../screens/client_signup_screen.dart';
import '../screens/org_login_screen.dart';
import '../screens/org_signup_screen.dart';
import '../screens/client_home_screen.dart';
import '../screens/org_home_screen.dart';

class AppRoutes {
  static const String selectLogin = '/';
  static const String clientLogin = '/client-login';
  static const String clientSignup = '/client-signup';
  static const String orgLogin = '/org-login';
  static const String orgSignup = '/org-signup';
  static const String clientHome = '/client-home';
  static const String orgHome = '/org-home';

  static Map<String, WidgetBuilder> routes = {
    selectLogin: (context) => const SelectLoginMethodScreen(),
    clientLogin: (context) => const ClientLoginScreen(),
    clientSignup: (context) => const ClientSignupScreen(),
    orgLogin: (context) => const OrgLoginScreen(),
    orgSignup: (context) => const OrgSignupScreen(),
    clientHome: (context) => const ClientHomeScreen(),
    orgHome: (context) => const OrgHomeScreen(),
  };
}
