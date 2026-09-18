import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/mental_health_question_model.dart';

/// Renders one screening question with its answer options.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  final MentalHealthQuestionModel question;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.text, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(question.options.length, (index) {
            final option = question.options[index];
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OptionButton(
                label: option,
                selected: isSelected,
                onTap: () => onSelect(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off_outlined,
                size: 20,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
