import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/models/user_model.dart';
import '../providers/admin_providers.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: SafeArea(
        child: AsyncValueView<List<UserModel>>(
          value: users,
          emptyIcon: Icons.people_outline,
          emptyTitle: 'No users found',
          onRetry: () => ref.invalidate(adminUsersProvider),
          builder: (data) => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final user = data[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.fullName.characters.first.toUpperCase()),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(user.email),
                  trailing: StatusBadge(
                    label: user.isAdmin ? 'Admin' : 'Patient',
                    tone:
                        user.isAdmin ? BadgeTone.warning : BadgeTone.neutral,
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
