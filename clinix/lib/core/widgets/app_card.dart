import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Base card used across the app: rounded corners, soft shadow, consistent
/// padding. Prefer [AppCard] over raw `Card`/`Container` styling.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      margin: margin,
      child: InkWell(
        // InkWell only materializes when tappable to keep semantics clean.
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
