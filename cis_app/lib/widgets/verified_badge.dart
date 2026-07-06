import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  final String status;
  final bool compact;

  const VerifiedBadge({
    super.key,
    required this.isVerified,
    this.status = '',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Colors.teal, size: compact ? 18 : 22),
          if (!compact) ...[
            const SizedBox(width: 6),
            const Text('Verified', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.teal)),
          ],
        ],
      );
    }

    final label = status.isEmpty ? 'Pending verification' : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_actions_rounded, color: Colors.orange.shade800, size: compact ? 14 : 18),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}
