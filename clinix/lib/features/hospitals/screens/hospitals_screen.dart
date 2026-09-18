import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/hospital_model.dart';
import '../../blood/widgets/blood_group_selector.dart';
import '../providers/hospital_providers.dart';

class HospitalsScreen extends ConsumerWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitals = ref.watch(filteredHospitalsProvider);
    final selectedGroup = ref.watch(hospitalBloodGroupFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hospitals')),
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
                hint: 'Search hospitals by name or location...',
                onChanged: (value) => ref
                    .read(hospitalSearchQueryProvider.notifier)
                    .state = value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('With available blood group:',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  BloodGroupSelector(
                    selected: selectedGroup,
                    onSelected: (group) => ref
                        .read(hospitalBloodGroupFilterProvider.notifier)
                        .state = group,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView<List<HospitalModel>>(
                value: hospitals,
                loading: const SkeletonList(),
                emptyIcon: Icons.local_hospital_outlined,
                emptyTitle: 'No hospitals found',
                emptyMessage: 'Try a different search or blood group filter.',
                onRetry: () => ref.invalidate(filteredHospitalsProvider),
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
                      _HospitalCard(hospital: data[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.hospital});

  final HospitalModel hospital;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final groups = hospital.bloodUnitsByGroup.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AppCard(
      onTap: () => _showDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.secondaryContainer,
                child: Icon(Icons.local_hospital_outlined,
                    color: colors.secondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name, style: theme.textTheme.titleMedium),
                    Text(hospital.location,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (hospital.isOpen24Hours)
                const StatusBadge(label: '24/7', tone: BadgeTone.info),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in groups)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: entry.value > 0
                        ? const Color(0xFFE2574C).withValues(alpha: 0.1)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: entry.value > 0
                          ? const Color(0xFFE2574C)
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Updated ${DateFormatters.relative(hospital.lastUpdated)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(hospital.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(hospital.location, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    StatusBadge(
                      label: '${hospital.totalUnits} total blood units',
                      tone: hospital.totalUnits > 0
                          ? BadgeTone.success
                          : BadgeTone.neutral,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (hospital.isOpen24Hours)
                      const StatusBadge(label: 'Open 24/7', tone: BadgeTone.info),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.showSnackBar(
                      'Calling ${hospital.phone ?? 'the hospital'} — wire url_launcher in production.',
                    );
                  },
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Contact hospital'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.showSnackBar(
                      'Map directions will open via url_launcher in production.',
                    );
                  },
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text('Get directions'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
