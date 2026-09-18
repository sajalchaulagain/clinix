import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

/// Compact notice bar used on AI / medicine / screening features so a safety
/// message is always visible without screaming for attention.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.info_outline,
              size: 16, color: colors.onPrimaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "AI-generated information" label chip for result screens.
class AiGeneratedLabel extends StatelessWidget {
  const AiGeneratedLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            AppStrings.aiInfoLabel,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontSize: 11, color: colors.primary),
          ),
        ],
      ),
    );
  }
}
