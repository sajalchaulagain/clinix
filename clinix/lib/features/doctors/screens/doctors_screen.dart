import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/models/doctor_model.dart';
import '../providers/doctor_providers.dart';
import '../widgets/doctor_card.dart';

class DoctorsScreen extends ConsumerWidget {
  const DoctorsScreen({super.key});

  static const _specialties = [
    'All',
    'General Physician',
    'Cardiologist',
    'Pediatrician',
    'Dermatologist',
    'Psychiatrist',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(filteredDoctorsProvider);
    final selectedSpecialty = ref.watch(doctorSpecialtyFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Doctor')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                0,
              ),
              child: AppSearchField(
                hint: 'Search doctors, specialties, location...',
                onChanged: (query) =>
                    ref.read(doctorQueryProvider.notifier).state = query,
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.sm,
                ),
                itemCount: _specialties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final specialty = _specialties[index];
                  final isSelected = specialty == 'All'
                      ? selectedSpecialty == null
                      : selectedSpecialty == specialty;
                  return ChoiceChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(doctorSpecialtyFilterProvider.notifier).state =
                          specialty == 'All' ? null : specialty;
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: AsyncValueView<List<DoctorModel>>(
                value: doctors,
                loading: const SkeletonList(),
                emptyIcon: Icons.medical_services_outlined,
                emptyTitle: 'No doctors found',
                emptyMessage:
                    'Try a different search term or specialty filter.',
                onRetry: () => ref.invalidate(filteredDoctorsProvider),
                builder: (data) => RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(filteredDoctorsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: data.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final doctor = data[index];
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () => context.push('/doctors/${doctor.id}', extra: doctor),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
