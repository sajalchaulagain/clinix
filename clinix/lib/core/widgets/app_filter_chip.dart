import 'package:flutter/material.dart';

/// Consistent selectable chip used by blood/doctor/medicine filter rows.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 18) : null,
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
    );
  }
}
