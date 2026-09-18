import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/notification_model.dart';
import '../data/mock_notification_repository.dart';
import '../domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  // BACKEND INTEGRATION: replace with API/Firestore-backed repository.
  return MockNotificationRepository();
});

class NotificationListNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() {
    return ref.read(notificationRepositoryProvider).getNotifications();
  }

  Future<void> markRead(NotificationModel item) async {
    await ref.read(notificationRepositoryProvider).markAsRead(item.id);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final n in current)
        if (n.id == item.id) n.copyWith(isRead: true) else n,
    ]);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final n in current) n.copyWith(isRead: true),
    ]);
  }

  Future<void> refresh() async {
    state = AsyncData(
      await ref.read(notificationRepositoryProvider).getNotifications(),
    );
  }
}

final notificationListProvider = AsyncNotifierProvider<NotificationListNotifier,
    List<NotificationModel>>(NotificationListNotifier.new);

/// Drives the bell badge on the home header.
final unreadNotificationsCountProvider = FutureProvider<int>((ref) {
  final list = ref.watch(notificationListProvider);
  return list.when(
    data: (items) => items.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
