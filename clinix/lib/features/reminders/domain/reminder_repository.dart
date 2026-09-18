import '../../../shared/models/reminder_model.dart';

/// Contract for medicine reminders.
///
/// DESIGN: reminders must work fully offline. The local implementation
/// persists to SharedPreferences and schedules device notifications. When the
/// backend sync exists, an ApiReminderRepository can mirror the same data to
/// the server without UI changes.
abstract class ReminderRepository {
  Future<List<ReminderModel>> getReminders();

  Future<ReminderModel> saveReminder(ReminderModel reminder);

  Future<void> deleteReminder(String id);

  Future<ReminderModel> setEnabled(String id, bool enabled);
}
