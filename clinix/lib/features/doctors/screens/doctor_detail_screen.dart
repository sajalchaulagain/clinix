import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/doctor_model.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colors.primaryContainer,
                      child: Icon(Icons.person,
                          size: 40, color: colors.primary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(doctor.name, style: theme.textTheme.headlineSmall),
                    Text(doctor.specialty, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(
                      label: doctor.isAvailableToday
                          ? 'Available today'
                          : 'Next slot: later this week',
                      tone: doctor.isAvailableToday
                          ? BadgeTone.success
                          : BadgeTone.neutral,
                      icon: doctor.isAvailableToday
                          ? Icons.check_circle_outline
                          : Icons.schedule,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: 'Hospital',
                        value: doctor.hospitalName),
                    const Divider(height: AppSpacing.lg),
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: doctor.location),
                    const Divider(height: AppSpacing.lg),
                    _InfoRow(
                        icon: Icons.work_outline,
                        label: 'Experience',
                        value: '${doctor.yearsExperience} years'),
                    if (doctor.consultationFee != null) ...[
                      const Divider(height: AppSpacing.lg),
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Consultation fee',
                        value:
                            'NPR ${doctor.consultationFee!.toStringAsFixed(0)}',
                      ),
                    ],
                  ],
                ),
              ),
              if (doctor.bio != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(doctor.bio!, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Book Appointment (coming soon)',
                icon: Icons.calendar_month_outlined,
                onPressed: () => context.showSnackBar(
                  'Appointment booking will be enabled in the backend phase.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
