import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/models/medicine_analysis_model.dart';
import '../../../shared/models/medicine_model.dart';
import '../providers/medicine_providers.dart';
import '../widgets/medicine_analysis_view.dart';

/// Medicine guide: search catalog -> tap -> full info sheet.
class MedicineInfoScreen extends ConsumerWidget {
  const MedicineInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(medicineSearchResultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Info')),
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
                hint: 'Search by name or generic name...',
                onChanged: (query) => ref
                    .read(medicineSearchQueryProvider.notifier)
                    .state = query,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: AsyncValueView<List<MedicineModel>>(
                value: results,
                loading: const SkeletonList(count: 3),
                emptyIcon: Icons.medication_outlined,
                emptyTitle: 'No medicines found',
                emptyMessage: 'Try searching by generic name, e.g. "ibuprofen".',
                onRetry: () => ref.invalidate(medicineSearchResultsProvider),
                builder: (medicines) => ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: medicines.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.medication_outlined,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(medicine.name,
                          style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        [
                          if (medicine.genericName != null)
                            medicine.genericName!,
                          if (medicine.category != null) medicine.category!,
                        ].join(' • '),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openInfo(context, ref, medicine),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInfo(BuildContext context, WidgetRef ref, MedicineModel medicine) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
          final infoAsync = ref.watch(medicineInfoProvider(medicine.id));
          return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      AsyncValueView<MedicineAnalysisModel>(
                        value: infoAsync,
                        onRetry: () =>
                            ref.invalidate(medicineInfoProvider(medicine.id)),
                        builder: (analysis) =>
                            MedicineAnalysisView(analysis: analysis),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          );
          },
        );
      },
    );
  }
}
