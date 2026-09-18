import '../../../core/services/notification_service.dart';
import '../../../shared/models/reminder_model.dart';

/// Bridges reminder data and scheduled local notifications.
///
/// Every add/edit/toggle/delete in the reminder feature goes through this
/// service so notification schedules stay perfectly in sync with stored data.
class ReminderService {
  ReminderService(this._notifications);

  final NotificationService _notifications;

  /// Schedules daily notifications for every time slot of [reminder].
  Future<void> scheduleFor(ReminderModel reminder) async {
    // Always cancel stale schedules first (idempotent updates).
    await cancelFor(reminder);
    if (!reminder.isEnabled) return;

    for (var i = 0; i < reminder.times.length; i++) {
      final parts = reminder.times[i].split(':');
      if (parts.length != 2) continue;
      await _notifications.scheduleDaily(
        id: reminder.notificationIdFor(i),
        title: 'Time for ${reminder.medicineName}',
        body: 'Dose: ${reminder.dosage} • ${reminder.frequency}',
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
  }

  Future<void> cancelFor(ReminderModel reminder) async {
    // Cancel up to the max times a reminder could have (times may change
    // between edits; extra cancels are harmless).
    for (var i = 0; i < 8; i++) {
      await _notifications.cancel(reminder.notificationIdFor(i));
    }
  }

  /// Reschedules everything, e.g. after the master notification toggle in
  /// settings flips back on, or after a time-zone change.
  Future<void> rescheduleAll(List<ReminderModel> reminders) async {
    await _notifications.cancelAll();
    for (final reminder in reminders) {
      await scheduleFor(reminder);
    }
  }
}
