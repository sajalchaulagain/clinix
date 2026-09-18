import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../shared/extensions/context_extensions.dart';

class ScreeningIntroScreen extends StatelessWidget {
  const ScreeningIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Well-being Screening')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.self_improvement_outlined,
                    size: 56, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'A gentle check-in with yourself',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Answer 10 short questions about how things have felt lately. '
                'You will receive a screening summary with general well-being '
                'indicators, coping ideas and guidance on when professional '
                'support could help.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FactChip(icon: Icons.schedule, label: '~3 minutes'),
                  const SizedBox(width: AppSpacing.sm),
                  _FactChip(icon: Icons.lock_outline, label: 'Private'),
                  const SizedBox(width: AppSpacing.sm),
                  _FactChip(icon: Icons.quiz_outlined, label: '10 questions'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const DisclaimerBanner(text: AppStrings.screeningDisclaimer),
              const Spacer(),
              AppButton(
                label: 'Start Screening',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.push('/mental-health/questions'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'In crisis? Skip the screening and contact local emergency '
                'services or a crisis helpline now.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
