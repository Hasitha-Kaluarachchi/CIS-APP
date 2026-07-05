import 'package:flutter/material.dart';

class AppSearchHeader extends StatelessWidget {
  final String appName;
  final String searchHint;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final ValueChanged<String>? onSearchSubmitted;
  final String? profileImagePath;

  const AppSearchHeader({
    super.key,
    required this.appName,
    required this.searchHint,
    required this.onProfileTap,
    required this.onNotificationTap,
    this.onSearchSubmitted,
    this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App name + notification bell
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3E2BCB),
                letterSpacing: 0.5,
              ),
            ),
            IconButton(
              onPressed: onNotificationTap,
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Profile icon + search bar
        Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFE6F4),
                backgroundImage: profileImagePath != null
                    ? AssetImage(profileImagePath!)
                    : null,
                child: profileImagePath == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF004D48),
                        size: 28,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF0E8F4),
                    suffixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF333333),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
