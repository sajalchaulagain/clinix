import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/blood_stock_model.dart';

class BloodDetailScreen extends StatelessWidget {
  const BloodDetailScreen({super.key, required this.stock});

  final BloodStockModel stock;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text('${stock.bloodGroup} Availability')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2574C).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        stock.bloodGroup,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFE2574C),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(stock.hospitalName,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xs),
                    Text(stock.location, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(
                      label: stock.availabilityLabel,
                      tone: stock.unitsAvailable <= 0
                          ? BadgeTone.error
                          : stock.unitsAvailable < 5
                              ? BadgeTone.warning
                              : BadgeTone.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    _row(context, 'Units available', '${stock.unitsAvailable}'),
                    const Divider(height: AppSpacing.lg),
                    _row(
                      context,
                      'Last updated',
                      DateFormatters.dateTime(stock.lastUpdated),
                    ),
                    const Divider(height: AppSpacing.lg),
                    _row(context, 'Location', stock.location),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Stock information is shared by hospitals and blood banks and '
                'can change quickly — always call ahead to confirm.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (stock.isAvailable)
                AppButton(
                  label: 'Request ${stock.bloodGroup} Blood',
                  icon: Icons.water_drop_outlined,
                  onPressed: () => context.push(
                    '/blood-request',
                    extra: stock.bloodGroup,
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => context.push('/blood-request'),
                  icon: const Icon(Icons.notification_add_outlined),
                  label: const Text('Submit an urgent request instead'),
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => context.showSnackBar(
                  'Calling will be wired to the hospital phone number via url_launcher.',
                ),
                icon: const Icon(Icons.call_outlined),
                label: const Text('Contact hospital'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
