import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/mental_health_answer_model.dart';
import '../../../shared/models/mental_health_question_model.dart';
import '../../../shared/models/mental_health_result_model.dart';
import '../data/mock_mental_health_repository.dart';
import '../domain/mental_health_repository.dart';

final mentalHealthRepositoryProvider = Provider<MentalHealthRepository>((ref) {
  // BACKEND INTEGRATION: replace with the API implementation once the
  // FastAPI screening contract is finalized.
  return MockMentalHealthRepository();
});

final screeningQuestionsProvider =
    FutureProvider.autoDispose<List<MentalHealthQuestionModel>>((ref) {
  return ref.watch(mentalHealthRepositoryProvider).getQuestions();
});

enum ScreeningStage { answering, processing, done }

class ScreeningState extends Equatable {
  const ScreeningState({
    this.answers = const {},
    this.currentIndex = 0,
    this.stage = ScreeningStage.answering,
    this.result,
    this.error,
  });

  /// questionId -> selected option index
  final Map<String, int> answers;
  final int currentIndex;
  final ScreeningStage stage;
  final MentalHealthResultModel? result;
  final String? error;

  int answeredCountFor(List<MentalHealthQuestionModel> questions) =>
      questions.where((q) => answers.containsKey(q.id)).length;

  bool isAnswered(String questionId) => answers.containsKey(questionId);

  ScreeningState copyWith({
    Map<String, int>? answers,
    int? currentIndex,
    ScreeningStage? stage,
    MentalHealthResultModel? result,
    String? error,
    bool clearError = false,
  }) {
    return ScreeningState(
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      stage: stage ?? this.stage,
      result: result ?? this.result,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [answers, currentIndex, stage, result, error];
}

/// Drives the question flow: select answers, advance, submit, hold result.
class ScreeningController extends AutoDisposeNotifier<ScreeningState> {
  @override
  ScreeningState build() => const ScreeningState();

  void selectOption(String questionId, int optionIndex) {
    state = state.copyWith(
      answers: {...state.answers, questionId: optionIndex},
    );
  }

  void goTo(int index, int questionCount) {
    final clamped = index.clamp(0, questionCount - 1);
    state = state.copyWith(currentIndex: clamped);
  }

  Future<void> submit(List<MentalHealthQuestionModel> questions) async {
    state = state.copyWith(stage: ScreeningStage.processing, clearError: true);
    final answers = [
      for (final question in questions)
        if (state.answers[question.id] != null)
          MentalHealthAnswerModel(
            questionId: question.id,
            selectedOptionIndex: state.answers[question.id]!,
            score: state.answers[question.id]!,
          ),
    ];
    try {
      final result =
          await ref.read(mentalHealthRepositoryProvider).analyze(answers);
      state = state.copyWith(stage: ScreeningStage.done, result: result);
    } catch (e) {
      state = state.copyWith(
        stage: ScreeningStage.answering,
        error: 'Could not analyze your answers right now. Please try again.',
      );
    }
  }
}

final screeningControllerProvider =
    AutoDisposeNotifierProvider<ScreeningController, ScreeningState>(
  ScreeningController.new,
);
