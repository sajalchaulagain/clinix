import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/models/hospital_model.dart';
import '../providers/admin_providers.dart';

/// Read-mostly hospital overview for admins. Full hospital onboarding will be
/// a backend-driven flow; inventory per hospital is edited via Blood Inventory.
class AdminHospitalsScreen extends ConsumerWidget {
  const AdminHospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitals = ref.watch(adminHospitalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hospitals')),
      body: SafeArea(
        child: AsyncValueView<List<HospitalModel>>(
          value: hospitals,
          loading: const SkeletonList(),
          emptyIcon: Icons.local_hospital_outlined,
          emptyTitle: 'No hospitals registered',
          onRetry: () => ref.invalidate(adminHospitalsProvider),
          builder: (data) => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final hospital = data[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_hospital_outlined),
                  ),
                  title: Text(hospital.name),
                  subtitle: Text(
                    '${hospital.location} • ${hospital.totalUnits} units in stock\n'
                    'Updated ${DateFormatters.relative(hospital.lastUpdated)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
