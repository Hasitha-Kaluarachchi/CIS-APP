import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../widgets/network_profile_avatar.dart';
import '../widgets/server_search_suggestions.dart';

class OrgHomeScreen extends StatefulWidget {
  const OrgHomeScreen({super.key});

  @override
  State<OrgHomeScreen> createState() => _OrgHomeScreenState();
}

class _OrgHomeScreenState extends State<OrgHomeScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getOrganizationProfile();
    if (mounted) setState(() => _profile = data);
  }

  Future<void> _showNotifications() async {
    if (_profile == null) {
      Navigator.pushNamed(context, AppRoutes.notifications);
      return;
    }

    final notifications = await ApiService.getNotifications('organization', _profile!['organization_id']);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Organization Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
              ? const Text('No new organization notifications')
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
    final orgName = (_profile?['organization_name'] ?? 'Organization').toString();

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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF3E2BCB)),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: _showNotifications, icon: const Icon(Icons.notifications_none_rounded, size: 28)),
                      IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.settings), icon: const Icon(Icons.settings_outlined, size: 27)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(context, AppRoutes.orgProfile);
                      _loadProfile();
                    },
                    child: NetworkProfileAvatar(
                      imagePath: _profile?['profile_picture'],
                      fallbackAsset: 'assets/images/org_profile.png',
                      fallbackIcon: Icons.business_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: ServerSearchSuggestions(
                      hintText: 'Search existing services for ideas...',
                      emptyText: 'No similar services found',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7D1031), Color(0xFFE44984)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create your business server, submit verification evidence, and edit your server anytime.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.createServer),
                          icon: const Icon(Icons.add_business_rounded),
                          label: const Text('Create Server'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF7D1031)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.myServers),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('My Servers'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Organization Tools', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _HomeTile(
                icon: Icons.category_rounded,
                title: 'Available Categories',
                subtitle: 'View categories and compare similar services',
                onTap: () => Navigator.pushNamed(context, AppRoutes.orgDiscoverArea),
              ),
              _HomeTile(
                icon: Icons.business_center_rounded,
                title: 'My Business Servers',
                subtitle: 'Edit or review verification status of created servers',
                onTap: () => Navigator.pushNamed(context, AppRoutes.myServers),
              ),
              _HomeTile(
                icon: Icons.person_rounded,
                title: 'Organization Profile',
                subtitle: 'Upload logo and update account profile details',
                onTap: () async {
                  await Navigator.pushNamed(context, AppRoutes.orgProfile);
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
          backgroundColor: const Color(0xFF7D1031).withValues(alpha: 0.12),
          child: Icon(icon, color: const Color(0xFF7D1031)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
