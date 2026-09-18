import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton.dart';
import '../../doctors/providers/doctor_providers.dart';
import '../../doctors/widgets/doctor_card.dart';
import '../widgets/feature_card.dart';

/// "Explore" tab: search across modules + feature directory + doctor list.
///
/// The search box currently filters doctors locally; once backend search
/// exists, the same field will query the FastAPI search endpoint(s).
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _query = '';

  static const _modules = [
    FeatureItem(
      title: AppConstants.aiAssistantName,
      subtitle: 'Ask health questions',
      icon: Icons.smart_toy_outlined,
      color: AppColors.primary,
      route: '/ai',
    ),
    FeatureItem(
      title: 'Medicine Scanner',
      subtitle: 'Identify medicines',
      icon: Icons.document_scanner_outlined,
      color: AppColors.accent,
      route: '/medicine-scanner',
    ),
    FeatureItem(
      title: 'Medicine Info',
      subtitle: 'Search medicine guide',
      icon: Icons.medication_outlined,
      color: Color(0xFF3A7CA5),
      route: '/medicine-info',
    ),
    FeatureItem(
      title: 'Mental Health',
      subtitle: 'Well-being screening',
      icon: Icons.self_improvement_outlined,
      color: Color(0xFF7C6BC4),
      route: '/mental-health',
    ),
    FeatureItem(
      title: AppConstants.ayurvedicAssistantName,
      subtitle: 'Ayurvedic support',
      icon: Icons.spa_outlined,
      color: Color(0xFF4E8A4F),
      route: '/ayurvedic',
    ),
    FeatureItem(
      title: 'Blood Stock',
      subtitle: 'Availability near you',
      icon: Icons.bloodtype_outlined,
      color: AppColors.bloodRed,
      route: '/blood',
    ),
    FeatureItem(
      title: 'Donors',
      subtitle: 'Become a donor',
      icon: Icons.volunteer_activism_outlined,
      color: Color(0xFF2E9E6B),
      route: '/donors',
    ),
    FeatureItem(
      title: 'Hospitals',
      subtitle: 'Find hospitals',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF5B84AE),
      route: '/hospitals',
    ),
    FeatureItem(
      title: 'Reminders',
      subtitle: 'Medicine schedules',
      icon: Icons.alarm,
      color: AppColors.warning,
      route: '/reminders',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final searching = _query.trim().isNotEmpty;
    final doctors = ref.watch(filteredDoctorsProvider);

    final visibleModules = searching
        ? _modules
            .where((m) =>
                m.title.toLowerCase().contains(_query.toLowerCase()) ||
                m.subtitle.toLowerCase().contains(_query.toLowerCase()))
            .toList()
        : _modules;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: AppSearchField(
                  hint: 'Search doctors, medicines, blood...',
                  onChanged: (value) {
                    setState(() => _query = value);
                    ref.read(doctorQueryProvider.notifier).state = value;
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    children: [
                      AppFilterChip(
                        label: 'AI Assistants',
                        icon: Icons.smart_toy_outlined,
                        selected: false,
                        onSelected: (_) => context.push('/ai'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppFilterChip(
                        label: 'Medicine',
                        icon: Icons.medication_outlined,
                        selected: false,
                        onSelected: (_) => context.push('/medicine-info'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppFilterChip(
                        label: 'Blood',
                        icon: Icons.bloodtype_outlined,
                        selected: false,
                        onSelected: (_) => context.push('/blood'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppFilterChip(
                        label: 'Hospitals',
                        icon: Icons.local_hospital_outlined,
                        selected: false,
                        onSelected: (_) => context.push('/hospitals'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: const SectionHeader(title: 'All Services'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.82,
                ),
                itemCount: visibleModules.length,
                itemBuilder: (context, index) {
                  final item = visibleModules[index];
                  return FeatureCard(
                    title: item.title,
                    icon: item.icon,
                    color: item.color,
                    onTap: () => context.push(item.route),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: Column(
                  children: [
                    SectionHeader(
                      title: searching
                          ? 'Doctors matching "$_query"'
                          : 'Top Rated Doctors',
                      actionLabel: 'See all',
                      onAction: () => context.push('/doctors'),
                    ),
                  ],
                ),
              ),
            ),
            doctors.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: SkeletonCard(),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: AppErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(filteredDoctorsProvider),
                ),
              ),
              data: (data) {
                if (data.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.search_off,
                                color: colors.onSurfaceVariant),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'No doctors found. Try another search.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    110,
                  ),
                  sliver: SliverList.separated(
                    itemCount: data.length > 4 ? 4 : data.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final doctor = data[index];
                      return DoctorCard(
                        doctor: doctor,
                        compact: true,
                        onTap: () =>
                            context.push('/doctors/${doctor.id}', extra: doctor),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
