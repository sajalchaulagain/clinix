import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = context.theme;
    final colors = context.colors;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Identity card ----
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        user.fullName.trim().isEmpty
                            ? '?'
                            : user.fullName.trim().characters.first
                                .toUpperCase(),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: colors.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(user.fullName, style: theme.textTheme.headlineSmall),
                    Text(user.email, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      children: [
                        StatusBadge(
                          label: user.isAdmin ? 'Admin account' : 'Patient account',
                          tone: user.isAdmin ? BadgeTone.warning : BadgeTone.info,
                          icon: user.isAdmin
                              ? Icons.admin_panel_settings_outlined
                              : Icons.person_outline,
                        ),
                        if (user.bloodGroup != null)
                          StatusBadge(
                            label: user.bloodGroup!,
                            tone: BadgeTone.error,
                            icon: Icons.bloodtype_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ---- Health info ----
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health information', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _infoRow(context, Icons.phone_outlined, 'Phone',
                        user.phone ?? 'Not set'),
                    _infoRow(context, Icons.cake_outlined, 'Date of birth',
                        user.dateOfBirth == null
                            ? 'Not set'
                            : DateFormatters.date(user.dateOfBirth!)),
                    _infoRow(context, Icons.bloodtype_outlined, 'Blood group',
                        user.bloodGroup ?? 'Not set'),
                    _infoRow(
                      context,
                      Icons.contact_emergency_outlined,
                      'Emergency contact',
                      user.emergencyContact ?? 'Not set',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ---- Actions ----
              _ActionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => context.push('/edit-profile'),
              ),
              _ActionTile(
                icon: Icons.monitor_heart_outlined,
                title: 'Medical Preferences',
                onTap: () => context.push('/medical-preferences'),
              ),
              _ActionTile(
                icon: Icons.notifications_outlined,
                title: 'Notification Settings',
                onTap: () => context.push('/settings'),
              ),
              _ActionTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                onTap: () => context.push('/legal/privacy'),
              ),
              _ActionTile(
                icon: Icons.info_outline,
                title: 'About CliniX',
                onTap: () => context.push('/legal/about'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                onPressed: () async {
                  final confirmed = await showConfirmationDialog(
                    context: context,
                    title: 'Log out?',
                    message: 'You will need to sign in again to use CliniX.',
                    confirmLabel: 'Log out',
                    isDestructive: true,
                  );
                  if (confirmed) {
                    await ref.read(authControllerProvider.notifier).signOut();
                    // Router redirect takes the user to /login automatically.
                  }
                },
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
