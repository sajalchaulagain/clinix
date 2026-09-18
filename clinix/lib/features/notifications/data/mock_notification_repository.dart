import '../../../shared/models/notification_model.dart';
import '../domain/notification_repository.dart';

/// ⚠️ MOCK — seeded demo notifications; read-state kept in memory.
class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository() {
    final now = DateTime.now();
    _items = [
      NotificationModel(
        id: 'n-1',
        type: AppNotificationType.reminder,
        title: 'Medicine reminder',
        body: 'Time for your Paracetamol 500mg dose.',
        createdAt: now.subtract(const Duration(minutes: 25)),
        payload: const {'route': '/reminders'},
      ),
      NotificationModel(
        id: 'n-2',
        type: AppNotificationType.bloodRequest,
        title: 'Blood request update',
        body: 'Your O- request at Bir Hospital is being reviewed.',
        createdAt: now.subtract(const Duration(hours: 3)),
        payload: const {'route': '/blood-request'},
      ),
      NotificationModel(
        id: 'n-3',
        type: AppNotificationType.bloodAvailability,
        title: 'A+ available nearby',
        body: 'Nepal Mediciti Hospital reports 12 units of A+ available.',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        payload: const {'route': '/blood'},
      ),
      NotificationModel(
        id: 'n-4',
        type: AppNotificationType.aiResult,
        title: 'Screening summary ready',
        body: 'Your well-being screening summary is available to view.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        payload: const {'route': '/mental-health'},
      ),
      NotificationModel(
        id: 'n-5',
        type: AppNotificationType.system,
        title: 'Welcome to CliniX',
        body: 'Complete your profile to get the most out of CliniX.',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        payload: const {'route': '/edit-profile'},
      ),
    ];
  }

  late List<NotificationModel> _items;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markAsRead(String id) async {
    _items = [
      for (final item in _items)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
  }

  @override
  Future<void> markAllAsRead() async {
    _items = [for (final item in _items) item.copyWith(isRead: true)];
  }
}
