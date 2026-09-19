import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/models/reminder_model.dart';
import '../data/local_reminder_repository.dart';
import '../domain/reminder_repository.dart';
import '../services/reminder_service.dart';

/// Single instance of the local notification service for the app.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref.watch(notificationServiceProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  // BACKEND INTEGRATION: add an ApiReminderRepository for server sync while
  // keeping LocalReminderRepository as the offline source of truth.
  return LocalReminderRepository(ref.watch(localStorageServiceProvider));
});

/// Bump to force reminder list reloads (used by pull-to-refresh on home).
final remindersRefreshTriggerProvider = StateProvider<int>((ref) => 0);

enum ReminderSaveStatus { successExact, successFallback, failure }

/// Loads + mutates reminders, keeping notification schedules in sync.
class ReminderListNotifier
    extends AsyncNotifier<List<ReminderModel>> {
  @override
  Future<List<ReminderModel>> build() {
    ref.watch(remindersRefreshTriggerProvider);
    return ref.read(reminderRepositoryProvider).getReminders();
  }

  Future<void> _reload() async {
    state = AsyncData(await ref.read(reminderRepositoryProvider).getReminders());
  }

  Future<ReminderSaveStatus> save(ReminderModel reminder, {bool isEdit = false}) async {
    try {
      await ref.read(reminderRepositoryProvider).saveReminder(reminder);
      final exact = await ref.read(reminderServiceProvider).scheduleFor(reminder);
      await _reload();
      return exact
          ? ReminderSaveStatus.successExact
          : ReminderSaveStatus.successFallback;
    } catch (_) {
      return ReminderSaveStatus.failure;
    }
  }

  Future<bool> toggleEnabled(ReminderModel reminder, bool enabled) async {
    try {
      final updated = await ref
          .read(reminderRepositoryProvider)
          .setEnabled(reminder.id, enabled);
      if (enabled) {
        await ref.read(reminderServiceProvider).scheduleFor(updated);
      } else {
        await ref.read(reminderServiceProvider).cancelFor(updated);
      }
      await _reload();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(ReminderModel reminder) async {
    try {
      await ref.read(reminderRepositoryProvider).deleteReminder(reminder.id);
      await ref.read(reminderServiceProvider).cancelFor(reminder);
      await _reload();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderModel>>(
  ReminderListNotifier.new,
);
