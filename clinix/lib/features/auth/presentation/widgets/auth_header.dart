import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Branded header for auth screens: app mark + name + tagline.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.monitor_heart_rounded,
              size: 38, color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppConstants.appName,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle ?? AppConstants.tagline,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
