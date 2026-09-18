import '../../../shared/models/notification_model.dart';

/// Contract for the notification center.
///
/// Note the separation of concerns:
///   * This repository manages the notification LIST you see in-app.
///   * Local device presentation is [NotificationService].
///   * Remote push delivery is [MessagingService] (FCM).
/// The backend will be the source of truth for the list in production.
abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
