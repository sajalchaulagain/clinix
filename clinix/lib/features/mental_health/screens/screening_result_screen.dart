import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/mental_health_result_model.dart';
import '../providers/screening_providers.dart';

class ScreeningResultScreen extends ConsumerWidget {
  const ScreeningResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(screeningControllerProvider).result;
    final theme = context.theme;
    final colors = context.colors;

    if (result == null) {
      // Direct navigation to the result route without a completed flow.
      return Scaffold(
        appBar: AppBar(title: const Text('Screening Summary')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No screening in progress.',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Start a Screening',
                  onPressed: () => context.go('/mental-health'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bandTone = switch (result.band) {
      WellbeingBand.stable => BadgeTone.success,
      WellbeingBand.mildConcern => BadgeTone.warning,
      WellbeingBand.elevatedConcern => BadgeTone.error,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Screening Summary')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    const AiGeneratedLabel(),
                    const SizedBox(height: AppSpacing.sm),
                    Text('General Well-being Indicators',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(
                      label: result.bandLabel,
                      tone: bandTone,
                      icon: switch (result.band) {
                        WellbeingBand.stable => Icons.check_circle_outline,
                        WellbeingBand.mildConcern => Icons.visibility_outlined,
                        WellbeingBand.elevatedConcern =>
                          Icons.priority_high_rounded,
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      result.summary,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ResultSection(
                title: 'Observations',
                icon: Icons.insights_outlined,
                color: colors.primary,
                items: result.observations,
              ),
              _ResultSection(
                title: 'Coping Suggestions',
                icon: Icons.spa_outlined,
                color: colors.secondary,
                items: result.copingSuggestions,
              ),
              _ResultSection(
                title: 'Lifestyle Suggestions',
                icon: Icons.directions_walk_outlined,
                color: const Color(0xFF2E9E6B),
                items: result.lifestyleSuggestions,
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent_outlined,
                            color: colors.error, size: 22),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('When to seek professional help',
                              style: theme.textTheme.titleMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(result.seekHelpGuidance,
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const DisclaimerBanner(text: AppStrings.screeningDisclaimer),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Done',
                onPressed: () => context.go('/home'),
              ),
              TextButton(
                onPressed: () => context.pushReplacement('/mental-health'),
                child: const Text('Retake screening'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: color)),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
