import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// Engaging but calm "scanning" animation shown while analysis runs.
class AnalysisLoadingView extends StatefulWidget {
  const AnalysisLoadingView({super.key});

  @override
  State<AnalysisLoadingView> createState() => _AnalysisLoadingViewState();
}

class _AnalysisLoadingViewState extends State<AnalysisLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _stepIndex = 0;

  static const _steps = [
    'Reading the medicine label...',
    'Identifying active ingredients...',
    'Preparing safety information...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )
      ..addListener(() {
        final step = (_controller.value * _steps.length).floor();
        if (step != _stepIndex && step < _steps.length) {
          setState(() => _stepIndex = step);
        }
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 96,
            width: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 96,
                  width: 96,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
                Icon(Icons.medication_outlined,
                    size: 40, color: colors.primary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Analyzing medicine',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _steps[_stepIndex],
              key: ValueKey(_stepIndex),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
