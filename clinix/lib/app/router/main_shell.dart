import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

/// Scaffold hosting the 5 bottom-nav tabs with a floating pill navigation bar.
///
/// Uses [StatefulShellRoute] so each tab keeps its own navigation stack and
/// scroll state — no giant conditional widget trees.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: AppStrings.navHome),
    (icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: AppStrings.navExplore),
    (icon: Icons.bloodtype_outlined, selectedIcon: Icons.bloodtype, label: AppStrings.navBlood),
    (icon: Icons.alarm, selectedIcon: Icons.alarm, label: AppStrings.navReminders),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: AppStrings.navProfile),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the current tab pops back to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true, // lets tab content scroll under the floating bar
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: AppSizes.bottomNavHeight,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _NavItem(
                  icon: _tabs[i].icon,
                  selectedIcon: _tabs[i].selectedIcon,
                  label: _tabs[i].label,
                  selected: navigationShell.currentIndex == i,
                  onTap: () => _onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: '$label tab',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: selected ? 1.12 : 1.0,
                  child: Icon(selected ? selectedIcon : icon,
                      color: color, size: 24),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
