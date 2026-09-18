import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../shared/models/medicine_analysis_model.dart';

/// Full reusable renderer for a [MedicineAnalysisModel]. Shared by the scan
/// result screen and the medicine-info detail screen.
class MedicineAnalysisView extends StatelessWidget {
  const MedicineAnalysisView({super.key, required this.analysis, this.showDisclaimer = true});

  final MedicineAnalysisModel analysis;
  final bool showDisclaimer;

  static const _sectionIcons = {
    'Common Uses': Icons.healing_outlined,
    'Common Side Effects': Icons.sick_outlined,
    'Precautions': Icons.shield_outlined,
    'Warnings': Icons.warning_amber_outlined,
    'Contraindications': Icons.block_outlined,
    'Drug Interactions': Icons.swap_horiz_outlined,
    'Storage': Icons.inventory_2_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (analysis.isAiGenerated) ...[
                const AiGeneratedLabel(),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(analysis.medicineName, style: theme.textTheme.headlineSmall),
              if (analysis.genericName != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'Generic: ${analysis.genericName}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
              if (analysis.dosageInformation != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule_outlined,
                        size: 18, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        analysis.dosageInformation!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        ...analysis.sections.entries.where((e) => e.value.isNotEmpty).map(
              (entry) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _sectionIcons[entry.key] ??
                                Icons.medical_information_outlined,
                            size: 20,
                            color: entry.key == 'Warnings' ||
                                    entry.key == 'Contraindications'
                                ? colors.error
                                : colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(entry.key,
                                style: theme.textTheme.titleMedium),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...entry.value.map(
                        (line) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•  ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.primary)),
                              Expanded(
                                child: Text(line,
                                    style: theme.textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        if (showDisclaimer) ...[
          const SizedBox(height: AppSpacing.md),
          const DisclaimerBanner(text: AppStrings.medicineInfoDisclaimer),
        ],
      ],
    );
  }
}
