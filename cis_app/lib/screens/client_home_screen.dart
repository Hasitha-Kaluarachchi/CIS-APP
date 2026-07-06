import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../widgets/network_profile_avatar.dart';
import '../widgets/server_search_suggestions.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getClientProfile();
    if (mounted) setState(() => _profile = data);
  }

  Future<void> _showNotifications() async {
    if (_profile == null) {
      Navigator.pushNamed(context, AppRoutes.notifications);
      return;
    }

    final notifications = await ApiService.getNotifications('client', _profile!['client_id']);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
              ? const Text('No new notifications')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return ListTile(
                      title: Text(item['title'] ?? 'Notification'),
                      subtitle: Text(item['message'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = (_profile?['username'] ?? 'Client').toString();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DATA NEXUS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3E2BCB),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showNotifications,
                        icon: const Icon(Icons.notifications_none_rounded, size: 28),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                        icon: const Icon(Icons.settings_outlined, size: 27),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(context, AppRoutes.userProfile);
                      _loadProfile();
                    },
                    child: NetworkProfileAvatar(
                      imagePath: _profile?['profile_picture'],
                      fallbackAsset: 'assets/images/user_profile.png',
                      fallbackIcon: Icons.person_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: ServerSearchSuggestions(
                      hintText: 'Search services, categories, locations...',
                      emptyText: 'No services found',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF004D48), Color(0xFF0A7C72)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $username',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Search verified and unverified organization services created inside Data Nexus.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.discoverArea),
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: const Text('Explore Available Categories'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF004D48),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _HomeTile(
                icon: Icons.category_rounded,
                title: 'Discover Area',
                subtitle: 'Browse services by available categories',
                onTap: () => Navigator.pushNamed(context, AppRoutes.discoverArea),
              ),
              _HomeTile(
                icon: Icons.person_rounded,
                title: 'My Profile',
                subtitle: 'Update your contact details and profile picture',
                onTap: () async {
                  await Navigator.pushNamed(context, AppRoutes.userProfile);
                  _loadProfile();
                },
              ),
              _HomeTile(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'Theme, language, notifications, support and app info',
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF004D48).withValues(alpha: 0.12),
          child: Icon(icon, color: const Color(0xFF004D48)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
