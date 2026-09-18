import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/reminders/providers/reminder_providers.dart';
import '../../../shared/models/reminder_model.dart';

/// Small dashboard-specific providers. Each widget watches only the provider
/// it needs, keeping rebuilds efficient.
final dashboardGreetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
});

/// Reminders scheduled for today, shown in the health summary card.
final todaysRemindersProvider = Provider<AsyncValue<List<ReminderModel>>>((ref) {
  final reminders = ref.watch(reminderListProvider);
  return reminders.whenData(
    (list) => list.where((reminder) => reminder.isActiveToday).toList(),
  );
});
