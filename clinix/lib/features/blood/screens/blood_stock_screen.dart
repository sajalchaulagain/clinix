import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../providers/blood_providers.dart';
import '../widgets/blood_availability_card.dart';
import '../widgets/blood_group_selector.dart';

/// "Blood" bottom-nav tab: availability search + your requests shortcut.
class BloodStockScreen extends ConsumerWidget {
  const BloodStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(bloodFilterProvider);
    final stocks = ref.watch(filteredBloodStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Stock'),
        actions: [
          IconButton(
            tooltip: 'My blood requests',
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () => context.push('/blood-request'),
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
                hint: 'Search by hospital or location...',
                onChanged: (query) => ref
                    .read(bloodFilterProvider.notifier)
                    .setQuery(query),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: BloodGroupSelector(
                selected: filter.bloodGroup,
                onSelected: (group) => ref
                    .read(bloodFilterProvider.notifier)
                    .setBloodGroup(group),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Available only'),
                    selected: filter.availableOnly,
                    onSelected: (value) => ref
                        .read(bloodFilterProvider.notifier)
                        .toggleAvailableOnly(value),
                  ),
                  const Spacer(),
                  if (filter.hasActiveFilters)
                    TextButton.icon(
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: const Text('Clear'),
                      onPressed: () =>
                          ref.read(bloodFilterProvider.notifier).clear(),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView<List<BloodStockModel>>(
                value: stocks,
                loading: const SkeletonList(),
                onRetry: () => ref.invalidate(filteredBloodStockProvider),
                emptyIcon: Icons.bloodtype_outlined,
                emptyTitle: 'No matching blood stock',
                emptyMessage:
                    'Try widening your filters, or submit a blood request so hospitals can respond.',
                builder: (data) => RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(filteredBloodStockProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                      AppSpacing.screenPadding,
                      110,
                    ),
                    itemCount: data.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        BloodAvailabilityCard(stock: data[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton.extended(
          heroTag: 'blood-request-fab',
          onPressed: () => context.push('/blood-request'),
          icon: const Icon(Icons.water_drop_outlined),
          label: const Text('Request Blood'),
        ),
      ),
    );
  }
}
