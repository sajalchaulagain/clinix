import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../auth/providers/auth_providers.dart';
import '../../doctors/providers/doctor_providers.dart';
import '../../doctors/widgets/doctor_card.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../reminders/providers/reminder_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/feature_card.dart';
import '../widgets/health_summary_card.dart';
import '../widgets/quick_action_card.dart';

/// Feature grid contents (declarative; easy to reorder).
const _features = [
  FeatureItem(
    title: AppConstants.aiAssistantName,
    subtitle: 'AI health chat',
    icon: Icons.smart_toy_outlined,
    color: AppColors.primary,
    route: '/ai',
  ),
  FeatureItem(
    title: 'Medicine Scanner',
    subtitle: 'Scan & learn',
    icon: Icons.document_scanner_outlined,
    color: AppColors.accent,
    route: '/medicine-scanner',
  ),
  FeatureItem(
    title: 'Mental Health',
    subtitle: 'Well-being check',
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF7C6BC4),
    route: '/mental-health',
  ),
  FeatureItem(
    title: 'Blood Stock',
    subtitle: 'Find blood',
    icon: Icons.bloodtype_outlined,
    color: AppColors.bloodRed,
    route: '/blood',
  ),
  FeatureItem(
    title: AppConstants.ayurvedicAssistantName,
    subtitle: 'Ayurvedic care',
    icon: Icons.spa_outlined,
    color: Color(0xFF4E8A4F),
    route: '/ayurvedic',
  ),
  FeatureItem(
    title: 'Reminders',
    subtitle: 'Never miss a dose',
    icon: Icons.alarm,
    color: AppColors.warning,
    route: '/reminders',
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final greeting = ref.watch(dashboardGreetingProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);
    final todaysReminders = ref.watch(todaysRemindersProvider);
    final recommendedDoctors = ref.watch(recommendedDoctorsProvider);
    final theme = context.theme;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(recommendedDoctorsProvider);
            ref.read(remindersRefreshTriggerProvider.notifier).state++;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.md,
                    AppSpacing.screenPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---- Header ----
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colors.primaryContainer,
                            child: Text(
                              _initial(user?.fullName),
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: colors.primary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm + 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting, ${user?.fullName.split(' ').first ?? 'there'}',
                                  style: theme.textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'How are you feeling today?',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          _NotificationBell(unreadCount: unread),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ---- Search entry (tap -> Explore tab with search) ----
                      SearchEntryField(
                        hint: 'Search doctors, medicines, blood...',
                        onTap: () => context.go('/explore'),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ---- Health summary ----
                      HealthSummaryCard(
                        todaysReminders:
                            todaysReminders.valueOrNull ?? const [],
                        bloodGroup: user?.bloodGroup,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ---- Feature grid ----
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth > 520 ? 3 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppSpacing.sm + 4,
                              mainAxisSpacing: AppSpacing.sm + 4,
                              childAspectRatio: 1.05,
                            ),
                            itemCount: _features.length,
                            itemBuilder: (context, index) {
                              final item = _features[index];
                              return FeatureCard(
                                title: item.title,
                                subtitle: item.subtitle,
                                icon: item.icon,
                                color: item.color,
                                onTap: () => context.push(item.route),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ---- Quick access ----
                      const SectionHeader(title: 'Quick Access'),
                      SizedBox(
                        height: 96,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            QuickActionCard(
                              title: 'Find Doctor',
                              icon: Icons.medical_services_outlined,
                              color: colors.primary,
                              onTap: () => context.push('/doctors'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            QuickActionCard(
                              title: 'Request Blood',
                              icon: Icons.water_drop_outlined,
                              color: AppColors.bloodRed,
                              onTap: () => context.push('/blood-request'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            QuickActionCard(
                              title: 'Hospitals',
                              icon: Icons.local_hospital_outlined,
                              color: colors.secondary,
                              onTap: () => context.push('/hospitals'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            QuickActionCard(
                              title: 'Medicine Info',
                              icon: Icons.medication_outlined,
                              color: AppColors.accent,
                              onTap: () => context.push('/medicine-info'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            QuickActionCard(
                              title: 'Donors',
                              icon: Icons.volunteer_activism_outlined,
                              color: const Color(0xFF4E8A4F),
                              onTap: () => context.push('/donors'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ---- Recommended doctors ----
                      SectionHeader(
                        title: 'Recommended Doctors',
                        actionLabel: 'See all',
                        onAction: () => context.push('/doctors'),
                      ),
                    ],
                  ),
                ),
              ),
              // Slivers can't be wrapped in generic widgets, so we map the
              // AsyncValue to real sliver widgets here.
              recommendedDoctors.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    child: Column(children: [SizedBox(height: 8), LinearProgressIndicator()]),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: AppErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(recommendedDoctorsProvider),
                  ),
                ),
                data: (doctors) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    110, // leaves room for the floating bottom nav
                  ),
                  sliver: SliverList.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        compact: true,
                        onTap: () =>
                            context.push('/doctors/${doctor.id}', extra: doctor),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initial(String? name) {
    if (name == null || name.trim().isEmpty) return 'C';
    return name.trim().characters.first.toUpperCase();
  }
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell({required this.unreadCount});

  final AsyncValue<int> unreadCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = unreadCount.valueOrNull ?? 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_outlined, size: 26),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.bloodRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
