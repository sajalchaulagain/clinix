import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/reminder_model.dart';

/// One reminder row: medicine info, time chips, enable switch, edit/delete.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final ReminderModel reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get _nextDoseLabel {
    if (!reminder.isEnabled || reminder.times.isEmpty) {
      return reminder.isEnabled ? 'No times set' : 'Paused';
    }
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final sorted = [...reminder.times]..sort();
    for (final time in sorted) {
      final parts = time.split(':');
      final minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (minutes > nowMinutes) {
        return 'Today at ${DateFormatters.reminderTime(time)}';
      }
    }
    return 'Tomorrow at ${DateFormatters.reminderTime(sorted.first)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: reminder.isEnabled
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                child: Icon(
                  Icons.medication_outlined,
                  color: reminder.isEnabled
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.medicineName,
                        style: theme.textTheme.titleMedium),
                    Text(
                      '${reminder.dosage} • ${reminder.frequency}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Semantics(
                label:
                    '${reminder.isEnabled ? 'Disable' : 'Enable'} reminder for ${reminder.medicineName}',
                child: Switch(
                  value: reminder.isEnabled,
                  onChanged: onToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final time in reminder.times)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.alarm, size: 14),
                  label: Text(DateFormatters.reminderTime(time)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule,
                  size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text('Next: $_nextDoseLabel',
                    style: theme.textTheme.bodySmall),
              ),
              IconButton(
                tooltip: 'Edit reminder',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Delete reminder',
                icon: Icon(Icons.delete_outline,
                    size: 20, color: colors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
