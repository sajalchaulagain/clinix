import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

enum BadgeTone { success, warning, error, info, neutral }

/// Small rounded label for availability/status information.
///
/// Status is communicated with both color AND text/icon so it stays
/// understandable for color-blind users (accessibility requirement).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.icon,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      BadgeTone.success => (colors.secondaryContainer, colors.onSecondaryContainer),
      BadgeTone.warning => (const Color(0xFFFFF1DE), const Color(0xFF8A5A13)),
      BadgeTone.error => (colors.errorContainer, colors.onErrorContainer),
      BadgeTone.info => (colors.primaryContainer, colors.onPrimaryContainer),
      BadgeTone.neutral => (
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
