import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Abstraction over `flutter_local_notifications`.
///
/// Everything that schedules or shows a LOCAL notification goes through this
/// service so the underlying plugin can be swapped later without touching
/// features (e.g. reminders). Push notifications (FCM) live separately in
/// [MessagingService].
class NotificationService {
  NotificationService();

  static const String _channelId = 'clinix_reminders';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDescription =
      'Notifications for scheduled medicine reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      // NOTE: for production, resolve the device zone with the
      // `flutter_timezone` package. tz.local defaults to UTC which may shift
      // scheduled times on devices outside UTC.
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      await requestPermissions();
      _initialized = true;
    } catch (e) {
      // Notifications are a convenience, never crash app startup because of them.
      debugPrint('NotificationService init failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    await _plugin.show(id, title, body, _details);
  }

  /// Schedules a DAILY repeating notification at [hour]:[minute] local time.
  ///
  /// [Reminders] map each reminder time to a unique notification id so they can
  /// be cancelled individually when a reminder is edited or disabled.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) return;
    final scheduled = _nextInstanceOf(hour, minute);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
