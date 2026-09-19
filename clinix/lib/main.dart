import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'core/services/local_storage_service.dart';
import 'features/reminders/providers/reminder_providers.dart';
import 'features/settings/providers/settings_providers.dart';

import 'firebase_options.dart';

/// App bootstrapper.
///
/// Order matters:
///   1. load .env (public config),
///   2. init local storage (needed by providers via override),
///   3. optionally init Firebase + local notifications (both failure-tolerant).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env is a bundled asset; only PUBLIC configuration lives there.
  await dotenv.load();

  final storage = await LocalStorageService.init();

  // Firebase is opt-in (USE_FIREBASE=true) until `flutterfire configure` has
  // been run. Guarded so the app always boots in mock mode.
  if (AppConfig.useFirebase) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully.');
    } catch (error, stackTrace) {
      debugPrint('Firebase initialization failed: $error\n$stackTrace');
    }
  }

  // Local notifications (reminders) — never block startup on this.
  final container = ProviderContainer(
    overrides: [
      localStorageServiceProvider.overrideWithValue(storage),
    ],
  );
  final notificationsEnabled =
      container.read(notificationsEnabledProvider);
  if (notificationsEnabled) {
    try {
      await container.read(notificationServiceProvider).init();
      final reminders =
          await container.read(reminderRepositoryProvider).getReminders();
      await container.read(reminderServiceProvider).rescheduleAll(reminders);
    } catch (e) {
      debugPrint('Failed to reschedule notifications on boot: $e');
    }
  }
  container.dispose();

  runApp(
    ProviderScope(
      overrides: [
        // The initialized storage instance is shared app-wide.
        localStorageServiceProvider.overrideWithValue(storage),
      ],
      child: const CliniXApp(),
    ),
  );
}
