import 'package:flutter/material.dart';
import '../widgets/verified_badge.dart';

class ServerDetailScreen extends StatelessWidget {
  const ServerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final server = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};

    final name = (server['server_name'] ?? 'Business Server').toString();
    final category = (server['category'] ?? 'Category not set').toString();
    final sector = (server['sector'] ?? 'Sector not set').toString();
    final description = (server['description'] ?? 'No description available').toString();
    final location = (server['location'] ?? 'Location not set').toString();
    final contact = (server['contact_number'] ?? 'Not available').toString();
    final email = (server['email'] ?? 'Not available').toString();
    final website = (server['website'] ?? 'Not available').toString();
    final regNumber = (server['registration_number'] ?? '').toString();
    final evidence = (server['verification_evidence'] ?? '').toString();
    final status = (server['verification_status'] ?? 'pending').toString();
    final isVerified = server['is_verified'] == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Server Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF004D48), Color(0xFF0A7C72)]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      child: Text(
                        name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (isVerified) const Icon(Icons.verified_rounded, color: Colors.white, size: 26),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('$category • $sector', style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                VerifiedBadge(isVerified: isVerified, status: status),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _section(
            title: 'About Organization',
            children: [Text(description, style: const TextStyle(height: 1.6))],
          ),
          _section(
            title: 'Contact Information',
            children: [
              _info(Icons.location_on_rounded, 'Location', location),
              _info(Icons.phone_rounded, 'Phone', contact),
              _info(Icons.email_rounded, 'Email', email),
              _info(Icons.language_rounded, 'Website', website),
            ],
          ),
          _section(
            title: 'Verification Information',
            children: [
              _info(Icons.verified_user_rounded, 'Status', isVerified ? 'Verified by developer/admin' : status),
              _info(Icons.badge_rounded, 'Registration Number', regNumber.isEmpty ? 'Not provided' : regNumber),
              _info(Icons.description_rounded, 'Evidence', evidence.isEmpty ? 'Not provided' : evidence),
              if (!isVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'This server is visible to clients, but the verified badge will appear only after developer/admin review.',
                    style: TextStyle(color: Colors.orange.shade900, height: 1.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF004D48)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
