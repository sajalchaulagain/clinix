import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/donor_model.dart';
import '../../blood/widgets/blood_group_selector.dart';
import '../providers/donor_providers.dart';

class DonorsScreen extends ConsumerWidget {
  const DonorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donors = ref.watch(filteredDonorsProvider);
    final selectedGroup = ref.watch(donorBloodGroupFilterProvider);
    final availableOnly = ref.watch(donorAvailableOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donors'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.volunteer_activism_outlined, size: 18),
            label: const Text('Become a donor'),
            onPressed: () => context.push('/donors/become'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                0,
              ),
              child: AppSearchField(
                hint: 'Search donors by name or location...',
                onChanged: (value) =>
                    ref.read(donorSearchQueryProvider.notifier).state = value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  BloodGroupSelector(
                    selected: selectedGroup,
                    onSelected: (group) => ref
                        .read(donorBloodGroupFilterProvider.notifier)
                        .state = group,
                  ),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Available now'),
                        selected: availableOnly,
                        onSelected: (value) => ref
                            .read(donorAvailableOnlyProvider.notifier)
                            .state = value,
                      ),
                      const Spacer(),
                      Text(
                        'Contact stays private',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.lock_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView<List<DonorModel>>(
                value: donors,
                loading: const SkeletonList(),
                emptyIcon: Icons.volunteer_activism_outlined,
                emptyTitle: 'No donors match',
                emptyMessage:
                    'Try another blood group or location — or register yourself as a donor.',
                onRetry: () => ref.invalidate(filteredDonorsProvider),
                builder: (data) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                  ),
                  itemCount: data.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _DonorCard(donor: data[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonorCard extends ConsumerWidget {
  const _DonorCard({required this.donor});

  final DonorModel donor;

  Future<void> _requestContact(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(donorActionControllerProvider.notifier)
        .requestContact(donor.id);
    if (context.mounted) {
      context.showSnackBar(
        success
            ? 'Request sent. ${donor.name.split(' ').first} will be notified and can share contact details with you.'
            : 'Could not send the request. Please try again.',
        isError: !success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  donor.name.characters.isEmpty
                      ? '?'
                      : donor.name.characters.first.toUpperCase(),
                  style:
                      theme.textTheme.titleMedium?.copyWith(color: colors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donor.name, style: theme.textTheme.titleMedium),
                    Text(
                      '${donor.location} • ${donor.totalDonations} donations',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (donor.lastDonationDate != null)
                      Text(
                        'Last donated ${DateFormatters.date(donor.lastDonationDate!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2574C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  donor.bloodGroup,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFE2574C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              StatusBadge(
                label: donor.isAvailable
                    ? (donor.isEligibleByDate
                        ? 'Available'
                        : 'Recently donated')
                    : 'Unavailable',
                tone: donor.isAvailable && donor.isEligibleByDate
                    ? BadgeTone.success
                    : BadgeTone.neutral,
                icon: donor.isAvailable
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: donor.isAvailable
                    ? () => _requestContact(context, ref)
                    : null,
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Request donor'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
