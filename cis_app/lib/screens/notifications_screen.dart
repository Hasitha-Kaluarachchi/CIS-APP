import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    Map<String, dynamic>? profile = await ApiService.getClientProfile();
    String receiverType = "client";
    int? receiverId = profile?["client_id"];

    if (receiverId == null) {
      profile = await ApiService.getOrganizationProfile();
      receiverType = "organization";
      receiverId = profile?["organization_id"];
    }

    if (receiverId != null) {
      final data = await ApiService.getNotifications(receiverType, receiverId);
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _loading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    await ApiService.markNotificationAsRead(id);
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF004D48),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification["is_read"] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: isRead
                              ? Colors.grey
                              : const Color(0xFF7D1031),
                        ),
                        title: Text(
                          notification["title"] ?? "",
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notification["message"] ?? ""),
                        trailing: isRead
                            ? null
                            : TextButton(
                                onPressed: () =>
                                    _markAsRead(notification["_id"]),
                                child: const Text("Read"),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}