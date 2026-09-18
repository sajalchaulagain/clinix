import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../shared/models/notification_model.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  (IconData, Color) _styleFor(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.reminder => (Icons.alarm, const Color(0xFFE9A03B)),
      AppNotificationType.bloodRequest =>
        (Icons.water_drop_outlined, const Color(0xFFE2574C)),
      AppNotificationType.bloodAvailability =>
        (Icons.bloodtype_outlined, const Color(0xFFE2574C)),
      AppNotificationType.system =>
        (Icons.info_outline, const Color(0xFF3E72A6)),
      AppNotificationType.aiResult =>
        (Icons.auto_awesome_outlined, const Color(0xFF2AA7A5)),
      AppNotificationType.appointment =>
        (Icons.calendar_month_outlined, const Color(0xFF7C6BC4)),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all),
            onPressed: () =>
                ref.read(notificationListProvider.notifier).markAllRead(),
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncValueView<List<NotificationModel>>(
          value: notifications,
          emptyIcon: Icons.notifications_off_outlined,
          emptyTitle: 'No notifications',
          emptyMessage: 'Reminders, blood updates and results will appear here.',
          onRetry: () => ref.read(notificationListProvider.notifier).refresh(),
          builder: (items) => RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final (icon, color) = _styleFor(item.type);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          item.isRead ? FontWeight.w500 : FontWeight.w800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.body, style: theme.textTheme.bodyMedium),
                      Text(
                        DateFormatters.relative(item.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: item.isRead
                      ? null
                      : CircleAvatar(
                          radius: 4,
                          backgroundColor: colors.primary,
                        ),
                  onTap: () {
                    ref.read(notificationListProvider.notifier).markRead(item);
                    final route = item.payload?['route'] as String?;
                    if (route != null && route.isNotEmpty) {
                      context.push(route);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
