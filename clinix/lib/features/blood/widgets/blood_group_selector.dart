import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';

/// Horizontal scrollable blood group picker (A+ ... O-).
class BloodGroupSelector extends StatelessWidget {
  const BloodGroupSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.bloodGroups.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final group = AppConstants.bloodGroups[index - 1];
          return ChoiceChip(
            label: Text(group),
            selected: selected == group,
            onSelected: (_) => onSelected(group),
          );
        },
      ),
    );
  }
}
