import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../widgets/verified_badge.dart';

class MyServersScreen extends StatefulWidget {
  const MyServersScreen({super.key});

  @override
  State<MyServersScreen> createState() => _MyServersScreenState();
}

class _MyServersScreenState extends State<MyServersScreen> {
  bool _isLoading = true;
  List<dynamic> _servers = [];

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    final data = await ApiService.getMyServers();
    if (!mounted) return;
    setState(() {
      _servers = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteServer(Map<String, dynamic> server) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Server?'),
        content: Text('Delete ${server['server_name'] ?? 'this server'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;
    final success = await ApiService.deleteServer((server['_id'] ?? '').toString());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Server deleted' : 'Delete failed')),
    );
    if (success) _loadServers();
  }

  Future<void> _editServer(Map<String, dynamic> server) async {
    await Navigator.pushNamed(context, AppRoutes.createServer, arguments: server);
    _loadServers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Business Servers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.createServer);
          _loadServers();
        },
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Create'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServers,
              child: _servers.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 90),
                        Icon(Icons.business_center_outlined, size: 70),
                        SizedBox(height: 18),
                        Center(child: Text('No business servers created yet.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _servers.length,
                      itemBuilder: (context, index) {
                        final server = Map<String, dynamic>.from(_servers[index]);
                        final verified = server['is_verified'] == true;
                        final status = (server['verification_status'] ?? 'pending').toString();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.serverDetails, arguments: server),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    server['server_name'] ?? 'Unnamed Server',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                VerifiedBadge(isVerified: verified, status: status, compact: true),
                              ],
                            ),
                            subtitle: Text('${server['category'] ?? ''} • ${server['sector'] ?? ''}\n${server['location'] ?? ''}'),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editServer(server);
                                if (value == 'delete') _deleteServer(server);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
