import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase Cloud Messaging wrapper.
///
/// Responsibilities:
///   * request notification permission (iOS + Android 13+),
///   * fetch the device FCM token (sent to the backend so it can target pushes),
///   * expose foreground message handling; local presentation is delegated to
///     [NotificationService] by the app bootstrapper.
///
/// FCM push CONTENT (blood request alerts, reminders sync, ...) is authored by
/// the backend — never by the client.
class MessagingService {
  MessagingService({FirebaseMessaging? instance})
      : _messaging = instance ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<void> init() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('MessagingService permission request failed: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('MessagingService getToken failed: $e');
      return null;
    }
  }

  /// Foreground messages: the app should present these via local notifications.
  Stream<RemoteMessage> onForegroundMessage() => FirebaseMessaging.onMessage;

  /// Token refresh stream; forward the new token to the backend.
  Stream<String> onTokenRefresh() => _messaging.onTokenRefresh;
}
