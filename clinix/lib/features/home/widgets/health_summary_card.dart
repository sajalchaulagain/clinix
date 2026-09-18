import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/reminder_model.dart';

/// "Your day at a glance" — today's medicine reminders + profile blood group.
class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({
    super.key,
    required this.todaysReminders,
    this.bloodGroup,
  });

  final List<ReminderModel> todaysReminders;
  final String? bloodGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      color: colors.primary,
      onTap: () => context.push('/reminders'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_outline, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Today\'s Health Summary',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _SummaryTile(
                icon: Icons.medication_outlined,
                label: 'Reminders today',
                value: '${todaysReminders.length}',
              ),
              const SizedBox(width: AppSpacing.md),
              _SummaryTile(
                icon: Icons.bloodtype_outlined,
                label: 'Blood group',
                value: bloodGroup ?? 'Not set',
              ),
            ],
          ),
          if (todaysReminders.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...todaysReminders.take(2).map(
                  (reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${reminder.medicineName} • ${reminder.dosage}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          reminder.times
                              .map(DateFormatters.reminderTime)
                              .join(', '),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
          ] else
            Text(
              'No medicine reminders for today. Stay healthy!',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
