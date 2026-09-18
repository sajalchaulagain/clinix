import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// Emergency guidance sheet, reachable from every AI/assistant surface.
///
/// Deliberately plain and action-oriented — this is where safety matters.
Future<void> showEmergencyGuidance(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    builder: (context) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.emergency_outlined, color: colors.error, size: 28),
                  const SizedBox(width: 12),
                  Text('Emergency Guidance', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'CliniX assistants cannot help in an emergency. '
                'If you or someone near you is in danger:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...[
                '• Call your local emergency number immediately.',
                '• If in Nepal, dial ${AppConstants.emergencyNumber} for an ambulance.',
                '• Go to the nearest emergency department.',
                '• For poisoning or severe allergic reaction, do not wait for a reply here.',
              ].map((line) => Text(line)),
              const SizedBox(height: 8),
              Text(
                'This app is a support tool — never delay emergency care because of it.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: colors.error),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Understood'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
