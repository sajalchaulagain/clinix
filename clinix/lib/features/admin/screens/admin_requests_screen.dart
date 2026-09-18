import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/blood_request_model.dart';
import '../providers/admin_providers.dart';

class AdminRequestsScreen extends ConsumerWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(adminRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Requests')),
      body: SafeArea(
        child: AsyncValueView<List<BloodRequestModel>>(
          value: requests,
          loading: const SkeletonList(),
          emptyIcon: Icons.assignment_outlined,
          emptyTitle: 'No requests',
          emptyMessage: 'Incoming blood requests will appear here.',
          onRetry: () => ref.invalidate(adminRequestsProvider),
          builder: (data) => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final request = data[index];
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${request.requesterName} • ${request.bloodGroup}',
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _urgencyChip(context, request.urgency),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${request.units} unit(s) • ${request.hospitalName}, ${request.location}\n'
                        '${request.reason ?? 'No reason provided'} • '
                        '${DateFormatters.relative(request.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: AppSpacing.lg),
                      Row(
                        children: [
                          Text('Status: ',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            request.status.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          PopupMenuButton<BloodRequestStatus>(
                            tooltip: 'Change status',
                            onSelected: (status) async {
                              final success = await ref
                                  .read(adminActionControllerProvider.notifier)
                                  .updateRequestStatus(request.id, status);
                              if (context.mounted) {
                                context.showSnackBar(
                                  success
                                      ? 'Request marked ${status.name}.'
                                      : 'Could not update status.',
                                  isError: !success,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              for (final status in BloodRequestStatus.values)
                                PopupMenuItem(
                                  value: status,
                                  child: Text(status.name),
                                ),
                            ],
                            child: const Padding(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              child: Icon(Icons.more_vert),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _urgencyChip(BuildContext context, BloodRequestUrgency urgency) {
    final color = switch (urgency) {
      BloodRequestUrgency.normal => Colors.blueGrey,
      BloodRequestUrgency.urgent => Colors.orange,
      BloodRequestUrgency.critical => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        urgency.name,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
