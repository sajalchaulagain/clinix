import 'package:flutter/material.dart';

/// Centered loading indicator. All data-driven screens should render this
/// while their provider is in the loading state.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!,
                style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
