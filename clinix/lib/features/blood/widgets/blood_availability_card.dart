import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/models/blood_stock_model.dart';

class BloodAvailabilityCard extends StatelessWidget {
  const BloodAvailabilityCard({super.key, required this.stock, this.onTap});

  final BloodStockModel stock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final tone = stock.unitsAvailable <= 0
        ? BadgeTone.error
        : stock.unitsAvailable < 5
            ? BadgeTone.warning
            : BadgeTone.success;

    return AppCard(
      onTap: onTap ?? () => context.push('/blood/${stock.id}', extra: stock),
      child: Row(
        children: [
          // Blood group medallion.
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE2574C).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stock.bloodGroup,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFE2574C),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.hospitalName,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: colors.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        stock.location,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Updated ${DateFormatters.relative(stock.lastUpdated)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${stock.unitsAvailable}',
                  style: theme.textTheme.headlineSmall),
              Text('units', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              StatusBadge(label: stock.availabilityLabel, tone: tone),
            ],
          ),
        ],
      ),
    );
  }
}
