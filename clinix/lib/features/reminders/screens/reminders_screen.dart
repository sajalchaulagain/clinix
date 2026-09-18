import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/reminder_model.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';

/// "Reminders" bottom-nav tab.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ReminderModel reminder,
  ) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete reminder?',
      message:
          'This removes the ${reminder.medicineName} schedule and its notifications.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    final success = await ref
        .read(reminderListProvider.notifier)
        .delete(reminder);
    if (context.mounted) {
      context.showSnackBar(
        success ? 'Reminder deleted.' : 'Could not delete. Try again.',
        isError: !success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminders')),
      body: SafeArea(
        child: AsyncValueView<List<ReminderModel>>(
          value: reminders,
          emptyIcon: Icons.alarm_off_outlined,
          emptyTitle: 'No reminders yet',
          emptyMessage:
              'Add a medicine schedule and CliniX will remind you at the right times — even offline.',
          onRetry: () =>
              ref.read(remindersRefreshTriggerProvider.notifier).state++,
          builder: (data) => RefreshIndicator(
            onRefresh: () async =>
                ref.read(remindersRefreshTriggerProvider.notifier).state++,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                110,
              ),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final reminder = data[index];
                return ReminderCard(
                  reminder: reminder,
                  onToggle: (enabled) async {
                    final success = await ref
                        .read(reminderListProvider.notifier)
                        .toggleEnabled(reminder, enabled);
                    if (!success && context.mounted) {
                      context.showSnackBar('Could not update the reminder.',
                          isError: true);
                    }
                  },
                  onEdit: () =>
                      context.push('/reminders/edit', extra: reminder),
                  onDelete: () => _confirmDelete(context, ref, reminder),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton.extended(
          heroTag: 'add-reminder-fab',
          onPressed: () => context.push('/reminders/add'),
          icon: const Icon(Icons.add_alarm),
          label: const Text('Add Reminder'),
        ),
      ),
    );
  }
}
