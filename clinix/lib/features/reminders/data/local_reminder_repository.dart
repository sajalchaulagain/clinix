import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../shared/models/reminder_model.dart';
import '../domain/reminder_repository.dart';

/// Offline-first reminder store (SharedPreferences JSON).
///
/// Deliberately durable across restarts so the demo behaves like a real app.
/// Sync to a backend can be layered on later (outbox pattern) — the UI and
/// scheduling logic won't change.
class LocalReminderRepository implements ReminderRepository {
  LocalReminderRepository(this._storage);

  final LocalStorageService _storage;

  List<ReminderModel> _readAll() {
    final raw = _storage.readJsonList(PrefsKeys.reminders);
    final reminders = raw.map(ReminderModel.fromJson).toList();
    reminders.sort((a, b) => a.medicineName.compareTo(b.medicineName));
    return reminders;
  }

  Future<void> _writeAll(List<ReminderModel> reminders) {
    final json = reminders.map((r) => r.toJson()).toList();
    return _storage.writeJsonList(PrefsKeys.reminders, json);
  }

  @override
  Future<List<ReminderModel>> getReminders() async => _readAll();

  @override
  Future<ReminderModel> saveReminder(ReminderModel reminder) async {
    final reminders = _readAll();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index >= 0) {
      reminders[index] = reminder;
    } else {
      reminders.add(reminder);
    }
    await _writeAll(reminders);
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    final reminders = _readAll()..removeWhere((r) => r.id == id);
    await _writeAll(reminders);
  }

  @override
  Future<ReminderModel> setEnabled(String id, bool enabled) async {
    final reminders = _readAll();
    final index = reminders.indexWhere((r) => r.id == id);
    if (index < 0) throw ArgumentError('Reminder not found: $id');
    final updated = reminders[index].copyWith(isEnabled: enabled);
    reminders[index] = updated;
    await _writeAll(reminders);
    return updated;
  }
}
