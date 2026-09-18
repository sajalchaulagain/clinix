import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';

/// Shown briefly while the app initializes (storage, auth state restore).
/// The GoRouter redirect decides where to go next — the splash has no logic.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.monitor_heart_rounded,
                  size: 56, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppConstants.tagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
