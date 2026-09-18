import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../shared/models/mental_health_question_model.dart';
import '../providers/screening_providers.dart';
import '../widgets/question_card.dart';
import '../widgets/screening_progress.dart';

class ScreeningQuestionsScreen extends ConsumerWidget {
  const ScreeningQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(screeningQuestionsProvider);
    final state = ref.watch(screeningControllerProvider);
    final controller = ref.read(screeningControllerProvider.notifier);

    ref.listen(screeningControllerProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
      }
      // When analysis completes, replace this screen with the result.
      if (next.stage == ScreeningStage.done && next.result != null) {
        context.pushReplacement('/mental-health/result');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Well-being Screening')),
      body: SafeArea(
        child: AsyncValueView<List<MentalHealthQuestionModel>>(
          value: questionsAsync,
          onRetry: () => ref.invalidate(screeningQuestionsProvider),
          builder: (questions) {
            final current = state.currentIndex.clamp(0, questions.length - 1);
            final question = questions[current];
            final isLast = current == questions.length - 1;
            final allAnswered =
                state.answeredCountFor(questions) == questions.length;
            final selected = state.answers[question.id];

            if (state.stage == ScreeningStage.processing) {
              return const _ProcessingView();
            }

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreeningProgress(
                      current: current + 1, total: questions.length),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: SingleChildScrollView(
                      child: QuestionCard(
                        question: question,
                        selectedIndex: selected,
                        onSelect: (index) =>
                            controller.selectOption(question.id, index),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      if (current > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                controller.goTo(current - 1, questions.length),
                            child: const Text('Back'),
                          ),
                        ),
                      if (current > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: isLast
                              ? (allAnswered ? 'Submit' : 'Finish remaining')
                              : 'Next',
                          onPressed: selected == null
                              ? null
                              : () {
                                  if (!isLast) {
                                    controller.goTo(
                                        current + 1, questions.length);
                                  } else if (allAnswered) {
                                    controller.submit(questions);
                                  } else {
                                    // Jump to first unanswered question.
                                    final firstUnanswered =
                                        questions.indexWhere(
                                      (q) => !state.isAnswered(q.id),
                                    );
                                    if (firstUnanswered >= 0) {
                                      controller.goTo(
                                          firstUnanswered, questions.length);
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your answers stay on this device in demo mode.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
            width: 72,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Preparing your screening summary...',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Reviewing general well-being patterns — this is not a diagnosis.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
