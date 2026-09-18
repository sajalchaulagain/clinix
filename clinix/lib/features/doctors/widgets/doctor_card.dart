import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/models/doctor_model.dart';

/// Reusable doctor card used by Home (recommended) and the doctors list.
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, this.onTap, this.compact = false});

  final DoctorModel doctor;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final avatar = CircleAvatar(
      radius: compact ? 24 : 28,
      backgroundColor: colors.primaryContainer,
      child: Text(
        _initials(doctor.name),
        style: theme.textTheme.titleMedium?.copyWith(color: colors.primary),
      ),
    );

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          avatar,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${doctor.specialty} • ${doctor.hospitalName}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 2),
                    Text(doctor.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.location_on_outlined,
                        size: 14, color: colors.onSurfaceVariant),
                    Text(doctor.location, style: theme.textTheme.bodySmall),
                    const Spacer(),
                    if (doctor.isAvailableToday)
                      const StatusBadge(
                        label: 'Today',
                        tone: BadgeTone.success,
                      )
                    else
                      const StatusBadge(label: 'Later'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.replaceAll('Dr. ', '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
