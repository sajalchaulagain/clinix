import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../domain/ayurvedic_repository.dart';
import '../providers/ayurvedic_providers.dart';

/// Baidyek Sathi home: symptom input, wellness categories, remedy cards.
class AyurvedicScreen extends ConsumerWidget {
  const AyurvedicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(ayurvedicSuggestionsProvider);
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Baidyek Sathi'),
            Text('Ayurvedic wellness support', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Chat with Baidyek Sathi',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/ayurvedic-chat'),
          ),
        ],
      ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      color: const Color(0xFF4E8A4F).withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.spa_outlined,
                              color: Color(0xFF4E8A4F), size: 32),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Traditional Ayurvedic wellness knowledge, '
                              'explained simply and safely.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSearchField(
                      hint: 'Describe a symptom, e.g. "poor sleep"',
                      onChanged: (value) => ref
                          .read(ayurvedicSymptomQueryProvider.notifier)
                          .state = value,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final category in const [
                            'Digestion',
                            'Immunity',
                            'Sleep & Recovery',
                            'Stress & Energy',
                            'Seasonal Care',
                          ])
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.sm),
                              child: ActionChip(
                                avatar: const Icon(Icons.eco_outlined,
                                    size: 16),
                                label: Text(category),
                                onPressed: () {
                                  // Map categories to a helpful symptom query.
                                  final mapping = {
                                    'Digestion': 'digestion',
                                    'Immunity': 'immunity',
                                    'Sleep & Recovery': 'sleep',
                                    'Stress & Energy': 'stress',
                                    'Seasonal Care': 'cold cough',
                                  };
                                  ref
                                      .read(ayurvedicSymptomQueryProvider
                                          .notifier)
                                      .state = mapping[category] ?? category;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const SectionHeader(title: 'Traditional Suggestions'),
                  ],
                ),
              ),
            ),
            suggestions.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  child: SkeletonCard(),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: AppErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(ayurvedicSuggestionsProvider),
                ),
              ),
              data: (remedies) => remedies.isEmpty
                  ? const SliverToBoxAdapter(
                      child: AppEmptyState(
                        icon: Icons.eco_outlined,
                        title: 'No suggestions found',
                        message:
                            'Try describing a common symptom like "cold" or "stress".',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.md,
                      ),
                      sliver: SliverList.separated(
                        itemCount: remedies.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) =>
                            _RemedyCard(remedy: remedies[index]),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  0,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                child: DisclaimerBanner(text: AppStrings.ayurvedicDisclaimer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemedyCard extends StatelessWidget {
  const _RemedyCard({required this.remedy});

  final AyurvedicRemedyModel remedy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF4E8A4F).withValues(alpha: 0.12),
            child:
                const Icon(Icons.eco_outlined, color: Color(0xFF4E8A4F)),
          ),
          title: Text(remedy.title, style: theme.textTheme.titleMedium),
          subtitle: Text(remedy.category, style: theme.textTheme.bodySmall),
          childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
          children: [
            _block(context, 'About', remedy.description),
            _block(context, 'Traditional use', remedy.traditionalUse),
            _block(context, 'Precautions', remedy.precautions,
                isCaution: true),
          ],
        ),
      ),
    );
  }

  Widget _block(BuildContext context, String title, String body,
      {bool isCaution = false}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCaution ? Icons.warning_amber_outlined : Icons.circle,
            size: isCaution ? 16 : 8,
            color: isCaution ? colors.error : colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
