import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/donor_model.dart';
import '../domain/admin_repository.dart';
import '../providers/admin_providers.dart';

class AdminDonorsScreen extends ConsumerWidget {
  const AdminDonorsScreen({super.key});

  Future<void> _remove(
      BuildContext context, WidgetRef ref, DonorModel donor) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Remove donor?',
      message: '${donor.name} will be removed from the donor directory.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!confirmed) return;
    final AdminRepository repo = ref.read(adminRepositoryProvider);
    await repo.removeDonor(donor.id);
    ref.invalidate(adminDonorsProvider);
    if (context.mounted) context.showSnackBar('Donor removed.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donors = ref.watch(adminDonorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Donors')),
      body: SafeArea(
        child: AsyncValueView<List<DonorModel>>(
          value: donors,
          loading: const SkeletonList(),
          emptyIcon: Icons.volunteer_activism_outlined,
          emptyTitle: 'No donors registered',
          onRetry: () => ref.invalidate(adminDonorsProvider),
          builder: (data) => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final donor = data[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(child: Text(donor.bloodGroup)),
                  title: Text(donor.name),
                  subtitle: Text(
                    '${donor.location} • ${donor.totalDonations} donations'
                    '${donor.lastDonationDate != null ? ' • last ${DateFormatters.date(donor.lastDonationDate!)}' : ''}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove donor',
                    icon: Icon(Icons.person_remove_outlined,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () => _remove(context, ref, donor),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
