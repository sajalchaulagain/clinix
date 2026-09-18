import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // ---- Appearance ----
            _SettingsGroup(
              title: 'Appearance',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto_outlined)),
                          ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode_outlined)),
                          ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode_outlined)),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (selection) => ref
                            .read(themeModeProvider.notifier)
                            .setMode(selection.first),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: Text(
                    language == 'ne' ? 'नेपाली (beta)' : 'English',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context, ref),
                ),
              ],
            ),

            // ---- Notifications ----
            _SettingsGroup(
              title: 'Notifications',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Enable notifications'),
                  subtitle: const Text('Reminders and important updates'),
                  value: notificationsEnabled,
                  onChanged: (value) => ref
                      .read(notificationsEnabledProvider.notifier)
                      .setEnabled(value),
                ),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Reminder schedules'),
                  subtitle: const Text('Manage medicine reminders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/reminders'),
                ),
              ],
            ),

            // ---- Privacy & safety ----
            _SettingsGroup(
              title: 'Privacy & Safety',
              children: [
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('AI usage disclaimer'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAiDisclaimer(context),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/legal/privacy'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of use'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/legal/terms'),
                ),
              ],
            ),

            // ---- Admin (role-gated entry; routes ALSO guarded in router) ----
            if (user?.isAdmin ?? false)
              _SettingsGroup(
                title: 'Administration',
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: const Text('Admin Dashboard'),
                    subtitle:
                        const Text('Inventory, donors, requests & users'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/admin'),
                  ),
                ],
              ),

            // ---- Account ----
            _SettingsGroup(
              title: 'Account',
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About CliniX'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/legal/about'),
                ),
                ListTile(
                  leading: Icon(Icons.logout,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Log out',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  onTap: () async {
                    final confirmed = await showConfirmationDialog(
                      context: context,
                      title: 'Log out?',
                      message:
                          'You will need to sign in again to use CliniX.',
                      confirmLabel: 'Log out',
                      isDestructive: true,
                    );
                    if (confirmed) {
                      await ref
                          .read(authControllerProvider.notifier)
                          .signOut();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'CliniX v1.0.0 (demo build)\nCliniX is a healthcare support platform. '
              'It does not replace professional medical care.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final current = ref.read(languageProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text('Choose language',
                  style: Theme.of(context).textTheme.titleLarge),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: current,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('नेपाली (Nepali)'),
                subtitle: const Text(
                    'Structure ready — full translation ships next release'),
                value: 'ne',
                groupValue: current,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  void _showAiDisclaimer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.verified_user_outlined),
        title: const Text('AI Usage Disclaimer'),
        content: const SingleChildScrollView(
          child: Text('${AppStrings.aiDisclaimer}\n\n'
              '${AppStrings.ayurvedicDisclaimer}\n\n'
              '${AppStrings.emergencyBannerText}'),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}
