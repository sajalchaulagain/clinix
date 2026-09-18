import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../errors/app_exception.dart';

/// Standard full-area error presentation with optional retry.
///
/// Accepts any [Object] so Riverpod `AsyncError` states can pass the original
/// error; [AppException] messages are surfaced directly.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
  });

  final Object error;
  final VoidCallback? onRetry;

  String get _message {
    if (error is AppException) return (error as AppException).message;
    return AppStrings.genericErrorBody;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 56, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(AppStrings.genericErrorTitle,
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
