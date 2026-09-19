import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/medicine_providers.dart';
import '../widgets/medicine_analysis_view.dart';

/// Results of a scan. With 2+ medicines, offers side-by-side comparison.
class MedicineScanResultScreen extends ConsumerWidget {
  const MedicineScanResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(scanAnalysisProvider);
    final results = analysis?.valueOrNull;

    if (results == null || results.isEmpty) {
      // Arrived here without running a scan.
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No analysis available yet.'),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Scan a Medicine',
                  onPressed: () => context.go('/medicine-scanner'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (results.length > 1) ...[
                AppCard(
                  child: Column(
                    children: [
                      Text(
                        '${results.length} medicines identified',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Compare side by side',
                        icon: Icons.compare_arrows_outlined,
                        onPressed: () => context.push(
                          '/medicine-comparison',
                          extra: results,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              for (var i = 0; i < results.length; i++) ...[
                if (results.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      i == 0 ? 'Medicine A' : (i == 1 ? 'Medicine B' : 'Medicine ${i + 1}'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                MedicineAnalysisView(analysis: results[i]),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton(
                label: 'Scan another medicine',
                icon: Icons.document_scanner_outlined,
                onPressed: () {
                  ref.read(selectedImagesProvider.notifier).clear();
                  ref.read(scanAnalysisProvider.notifier).reset();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
