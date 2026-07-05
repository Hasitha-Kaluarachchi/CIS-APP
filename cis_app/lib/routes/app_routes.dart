import 'package:flutter/material.dart';

import '../screens/select_login_method_screen.dart';
import '../screens/client_login_screen.dart';
import '../screens/client_signup_screen.dart';
import '../screens/org_login_screen.dart';
import '../screens/org_signup_screen.dart';
import '../screens/client_home_screen.dart';
import '../screens/org_home_screen.dart';
import '../screens/discover_area_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/org_profile_screen.dart';
import '../screens/org_discover_area_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/category_organizations_screen.dart';
import '../screens/create_server_screen.dart';
import '../screens/server_detail_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/my_servers_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String selectLoginMethod = '/';
  static const String clientLogin = '/client-login';
  static const String clientSignup = '/client-signup';
  static const String orgLogin = '/org-login';
  static const String orgSignup = '/org-signup';
  static const String clientHome = '/client-home';
  static const String orgHome = '/org-home';
  static const String discoverArea = '/discover-area';
  static const String userProfile = '/user-profile';
  static const String orgProfile = '/org-profile';
  static const String orgDiscoverArea = '/org-discover-area';
  static const String notifications = '/notifications';
  static const String categoryOrganizations = '/category-organizations';
  static const String createServer = '/create-server';
  static const String serverDetails = '/server-details';
  static const String settings = '/settings';
  static const String myServers = '/my-servers';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    selectLoginMethod: (context) => const SelectLoginMethodScreen(),
    clientLogin: (context) => const ClientLoginScreen(),
    clientSignup: (context) => const ClientSignupScreen(),
    orgLogin: (context) => const OrgLoginScreen(),
    orgSignup: (context) => const OrgSignupScreen(),
    clientHome: (context) => const ClientHomeScreen(),
    orgHome: (context) => const OrgHomeScreen(),
    discoverArea: (context) => const DiscoverAreaScreen(),
    userProfile: (context) => const UserProfileScreen(),
    orgProfile: (context) => const OrgProfileScreen(),
    orgDiscoverArea: (context) => const OrgDiscoverAreaScreen(),
    notifications: (context) => const NotificationsScreen(),
    categoryOrganizations: (context) => const CategoryOrganizationsScreen(),
    createServer: (context) => const CreateServerScreen(),
    serverDetails: (context) => const ServerDetailScreen(),
    settings: (context) => const SettingsScreen(),
    myServers: (context) => const MyServersScreen(),
  };
}
