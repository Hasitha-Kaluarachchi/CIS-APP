import 'dart:async';

import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import 'verified_badge.dart';

class ServerSearchSuggestions extends StatefulWidget {
  final String hintText;
  final String emptyText;

  const ServerSearchSuggestions({
    super.key,
    this.hintText = 'Search services or organizations...',
    this.emptyText = 'No matching services found',
  });

  @override
  State<ServerSearchSuggestions> createState() => _ServerSearchSuggestionsState();
}

class _ServerSearchSuggestionsState extends State<ServerSearchSuggestions> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<dynamic> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final query = value.trim();
      _lastQuery = query;

      if (query.length < 2) {
        if (mounted) setState(() => _results = []);
        return;
      }

      if (mounted) setState(() => _isLoading = true);
      final data = await ApiService.searchServers(query);
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _results = data;
        _isLoading = false;
      });
    });
  }

  void _openServer(dynamic server) {
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(context, AppRoutes.serverDetails, arguments: server);
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _controller.text.trim().length >= 2;

    return Column(
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (value) => _onChanged(value),
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : const Color(0xFFF0E8F4),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _results = []);
                    },
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (showSuggestions)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 270),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(widget.emptyText),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final server = _results[index] as Map<String, dynamic>;
                          final verified = server['is_verified'] == true;
                          final status = (server['verification_status'] ?? 'pending').toString();

                          return ListTile(
                            onTap: () => _openServer(server),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF004D48).withValues(alpha: 0.12),
                              child: Text(
                                (server['server_name'] ?? 'S').toString().trim().isEmpty
                                    ? 'S'
                                    : (server['server_name'] ?? 'S').toString().trim()[0].toUpperCase(),
                                style: const TextStyle(color: Color(0xFF004D48), fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (server['server_name'] ?? 'Unnamed Server').toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                VerifiedBadge(isVerified: verified, status: status, compact: true),
                              ],
                            ),
                            subtitle: Text(
                              '${server['category'] ?? ''} • ${server['location'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                          );
                        },
                      ),
          ),
      ],
    );
  }
}
