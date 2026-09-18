import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../shared/models/medicine_analysis_model.dart';

/// Side-by-side comparison of 2–4 analyses (passed via `extra`).
class MedicineComparisonScreen extends StatelessWidget {
  const MedicineComparisonScreen({super.key, required this.analyses});

  final List<MedicineAnalysisModel> analyses;

  static const _labels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final columns = analyses.length.clamp(2, 4);

    final rows = <_ComparisonRow>[
      _ComparisonRow(
        'Generic name',
        analyses.map((a) => a.genericName ?? '—').toList(),
      ),
      _ComparisonRow(
        'Common uses',
        analyses.map((a) => _join(a.commonUses)).toList(),
      ),
      _ComparisonRow(
        'Side effects',
        analyses.map((a) => _join(a.commonSideEffects)).toList(),
      ),
      _ComparisonRow(
        'Precautions',
        analyses.map((a) => _join(a.precautions)).toList(),
      ),
      _ComparisonRow(
        'Interactions',
        analyses
            .map((a) => _join(a.interactions.map((i) => i.interactsWith).toList()))
            .toList(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Comparison')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AiGeneratedLabel(),
              const SizedBox(height: AppSpacing.sm),
              // Header row with medicine names.
              Row(
                children: [
                  const SizedBox(width: 92),
                  for (var i = 0; i < columns; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: colors.primaryContainer,
                              child: Text(_labels[i],
                                  style: TextStyle(color: colors.primary)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              analyses[i].medicineName,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final row in rows)
                AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm + 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          row.label,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      for (var i = 0; i < columns; i++)
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              row.values[i],
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Important differences',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _differencesSummary(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const DisclaimerBanner(text: AppStrings.medicineInfoDisclaimer),
            ],
          ),
        ),
      ),
    );
  }

  static String _join(List<String> items) =>
      items.isEmpty ? '—' : items.join('\n');

  /// Plain-language difference summary. In production this text comes from
  /// the backend comparison endpoint; here we derive a simple demo summary.
  String _differencesSummary() {
    if (analyses.length < 2) return 'Add at least two medicines to compare.';
    final a = analyses.first;
    final b = analyses[1];
    final aInteractions = a.interactions.length;
    final bInteractions = b.interactions.length;
    final buffer = StringBuffer()
      ..writeln('• Medicine A (${a.medicineName}) lists $aInteractions '
          'known interaction${aInteractions == 1 ? '' : 's'}; '
          'Medicine B (${b.medicineName}) lists $bInteractions.')
      ..writeln('• Dosage guidance differs — always follow the label or '
          'a pharmacist\'s advice for each medicine.')
      ..write('• Never combine medicines without checking with a '
          'healthcare professional.');
    return buffer.toString();
  }
}

class _ComparisonRow {
  const _ComparisonRow(this.label, this.values);

  final String label;
  final List<String> values;
}
