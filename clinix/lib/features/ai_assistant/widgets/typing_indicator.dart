import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// Three animated dots shown while the assistant "thinks".
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value - index * 0.2) % 1;
                final scale = 0.7 + 0.3 * (phase < 0.5 ? phase * 2 : 2 - phase * 2);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Transform.scale(
                    scale: scale,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: colors.primary,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
