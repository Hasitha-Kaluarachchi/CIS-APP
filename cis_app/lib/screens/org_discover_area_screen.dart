import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/server_search_suggestions.dart';

class OrgDiscoverAreaScreen extends StatelessWidget {
  const OrgDiscoverAreaScreen({super.key});

  static const List<Map<String, dynamic>> categories = [
    {
      'title': 'Health Services',
      'description': 'Hospitals, clinics, public health and medical support.',
      'icon': Icons.local_hospital_rounded,
    },
    {
      'title': 'Education Services',
      'description': 'Schools, institutes, training and learning services.',
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Business Services',
      'description': 'Business registration, support and private services.',
      'icon': Icons.business_center_rounded,
    },
    {
      'title': 'Administrative Services',
      'description': 'Administrative and citizen support services.',
      'icon': Icons.account_balance_rounded,
    },
  ];

  void _openCategory(BuildContext context, String categoryTitle) {
    Navigator.pushNamed(context, AppRoutes.categoryOrganizations, arguments: categoryTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Discover'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.myServers), icon: const Icon(Icons.business_center_rounded)),
          IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.settings), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const ServerSearchSuggestions(
            hintText: 'Search existing services for ideas...',
            emptyText: 'No similar services found',
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7D1031), Color(0xFFE44984)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage Organization Services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text(
                  'Browse existing services before creating your own business server.',
                  style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.createServer),
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Create Business Server'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF7D1031)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Available Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          for (final category in categories)
            _CategoryCard(
              icon: category['icon'],
              title: category['title'],
              description: category['description'],
              onTap: () => _openCategory(context, category['title']),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CategoryCard({required this.icon, required this.title, required this.description, required this.onTap});

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
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
