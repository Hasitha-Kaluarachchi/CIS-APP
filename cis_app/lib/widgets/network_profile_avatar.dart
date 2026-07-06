import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NetworkProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final String fallbackAsset;
  final IconData fallbackIcon;
  final double radius;

  const NetworkProfileAvatar({
    super.key,
    required this.imagePath,
    required this.fallbackAsset,
    required this.fallbackIcon,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.imageUrl(imagePath);
    ImageProvider? provider;

    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        provider = NetworkImage(imageUrl);
      } else {
        provider = AssetImage(fallbackAsset);
      }
    } else {
      provider = AssetImage(fallbackAsset);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEFE6F4),
      backgroundImage: provider,
      onBackgroundImageError: (_, __) {},
      child: imageUrl.isEmpty
          ? Icon(fallbackIcon, color: const Color(0xFF004D48), size: radius)
          : null,
    );
  }
}
