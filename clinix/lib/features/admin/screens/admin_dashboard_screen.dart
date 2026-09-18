import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../domain/admin_repository.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminStatsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Overview'),
                const SizedBox(height: AppSpacing.sm),
                AsyncValueView<AdminStats>(
                  value: stats,
                  onRetry: () => ref.invalidate(adminStatsProvider),
                  builder: (data) => GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.15,
                    children: [
                      AdminStatCard(
                        title: 'Total Donors',
                        value: '${data.totalDonors}',
                        icon: Icons.volunteer_activism_outlined,
                        color: const Color(0xFF2E9E6B),
                        onTap: () => context.push('/admin/donors'),
                      ),
                      AdminStatCard(
                        title: 'Blood Units Available',
                        value: '${data.availableBloodUnits}',
                        icon: Icons.bloodtype_outlined,
                        color: AppColors.bloodRed,
                        onTap: () => context.push('/admin/inventory'),
                      ),
                      AdminStatCard(
                        title: 'Blood Requests',
                        value: '${data.totalBloodRequests}',
                        icon: Icons.assignment_outlined,
                        color: AppColors.primary,
                        onTap: () => context.push('/admin/requests'),
                      ),
                      AdminStatCard(
                        title: 'Pending Requests',
                        value: '${data.pendingRequests}',
                        icon: Icons.pending_actions_outlined,
                        color: AppColors.warning,
                        onTap: () => context.push('/admin/requests'),
                      ),
                      AdminStatCard(
                        title: 'Hospitals',
                        value: '${data.registeredHospitals}',
                        icon: Icons.local_hospital_outlined,
                        color: AppColors.accent,
                        onTap: () => context.push('/admin/hospitals'),
                      ),
                      AdminStatCard(
                        title: 'Registered Users',
                        value: '${data.totalUsers}',
                        icon: Icons.people_outline,
                        color: const Color(0xFF7C6BC4),
                        onTap: () => context.push('/admin/users'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Manage'),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bloodtype_outlined),
                        title: const Text('Blood Inventory'),
                        subtitle: const Text('Add, update, remove stock'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/admin/inventory'),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.assignment_outlined),
                        title: const Text('Blood Requests'),
                        subtitle: const Text('Review & update statuses'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/admin/requests'),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading:
                            const Icon(Icons.notifications_active_outlined),
                        title: const Text('Broadcast Notification'),
                        subtitle: const Text('Send an update to users'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/admin/notifications'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
