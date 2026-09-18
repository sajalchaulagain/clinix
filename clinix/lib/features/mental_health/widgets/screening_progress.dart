import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// Linear progress with "Question X of Y" label.
class ScreeningProgress extends StatelessWidget {
  const ScreeningProgress({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = total == 0 ? 0.0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $current of $total',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text('${(progress * 100).round()}%',
                style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
