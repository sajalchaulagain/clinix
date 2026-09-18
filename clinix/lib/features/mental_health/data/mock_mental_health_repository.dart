import '../../../shared/models/mental_health_answer_model.dart';
import '../../../shared/models/mental_health_question_model.dart';
import '../../../shared/models/mental_health_result_model.dart';
import '../domain/mental_health_repository.dart';

/// ⚠️ MOCK — UI development only.
///
/// The demo score-banding below is ONLY to exercise the result UI. It uses
/// carefully worded, non-diagnostic output and will be replaced entirely by
/// the backend's AI-assisted analysis.
class MockMentalHealthRepository implements MentalHealthRepository {
  static const _frequencyOptions = ['Never', 'Rarely', 'Sometimes', 'Often'];

  static final _questions = [
    const MentalHealthQuestionModel(
      id: 'mh-1',
      text: 'Over the last two weeks, how often have you felt little interest or pleasure in doing things?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-2',
      text: 'How often have you felt down, depressed, or hopeless?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-3',
      text: 'How often have you had trouble falling or staying asleep, or sleeping too much?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-4',
      text: 'How often have you felt tired or had little energy?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-5',
      text: 'How often have you felt nervous, anxious, or on edge?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-6',
      text: 'How often have you been unable to stop or control worrying?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-7',
      text: 'How often have you had trouble concentrating on things like reading or watching TV?',
      type: MentalHealthQuestionType.frequencyScale,
      options: _frequencyOptions,
    ),
    const MentalHealthQuestionModel(
      id: 'mh-8',
      text: 'Do you feel connected to supportive friends or family?',
      type: MentalHealthQuestionType.yesNo,
      options: ['Yes', 'Sometimes', 'No'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-9',
      text: 'How often do you make time for activities that recharge you (walks, hobbies, rest)?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Regularly', 'Sometimes', 'Rarely', 'Almost never'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-10',
      text: 'How would you rate your overall stress level lately?',
      type: MentalHealthQuestionType.multipleChoice,
      options: ['Low', 'Moderate', 'High', 'Very high'],
    ),
  ];

  @override
  Future<List<MentalHealthQuestionModel>> getQuestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _questions;
  }

  @override
  Future<MentalHealthResultModel> analyze(
    List<MentalHealthAnswerModel> answers,
  ) async {
    // Simulated AI processing latency.
    await Future<void>.delayed(const Duration(milliseconds: 1800));

    final total = answers.fold<int>(0, (sum, a) => sum + a.score);
    final max = answers.fold<int>(
      0,
      (sum, a) {
        final question = _questions.firstWhere((q) => q.id == a.questionId);
        return sum + question.options.length - 1;
      },
    );

    final ratio = max == 0 ? 0.0 : total / max;
    final band = ratio < 0.33
        ? WellbeingBand.stable
        : ratio < 0.66
            ? WellbeingBand.mildConcern
            : WellbeingBand.elevatedConcern;

    return MentalHealthResultModel(
      band: band,
      totalScore: total,
      maxScore: max,
      summary: switch (band) {
        WellbeingBand.stable =>
          'Your answers suggest your general well-being indicators look fairly stable right now. Keep nurturing the habits that support you.',
        WellbeingBand.mildConcern =>
          'Some of your answers point to areas that may deserve a little extra care and attention in the coming weeks.',
        WellbeingBand.elevatedConcern =>
          'Several answers suggest you may be carrying a heavier load than usual. Reaching out for support would be a healthy next step.',
      },
      observations: switch (band) {
        WellbeingBand.stable => [
            'Sleep, energy and mood indicators appear mostly balanced.',
            'You report reasonable access to support and recharge time.',
          ],
        WellbeingBand.mildConcern => [
            'Some sleep or energy fluctuations show up in your answers.',
            'Worry or stress appears present on more days than not.',
          ],
        WellbeingBand.elevatedConcern => [
            'Low mood, energy or persistent worry appear frequently.',
            'Everyday activities may feel harder than usual right now.',
          ],
      },
      copingSuggestions: const [
        'Try 5 minutes of slow breathing when things feel heavy.',
        'Break the day into small, achievable tasks — and acknowledge finishing them.',
        'Talk with one person you trust about how you are doing.',
        'Write down one thing that went okay today, however small.',
      ],
      lifestyleSuggestions: const [
        'Keep a regular sleep and wake time where possible.',
        'Short daily walks or light movement can support mood.',
        'Stay hydrated and keep regular meal times.',
        'Limit late-night screen time and stimulants in the evening.',
      ],
      seekHelpGuidance: switch (band) {
        WellbeingBand.stable =>
          'If your feelings change or daily life gets harder, reaching out early to a counsellor or doctor is a strong step — not a last resort.',
        WellbeingBand.mildConcern =>
          'Consider talking with a counsellor or your doctor if these feelings persist for a couple of weeks or affect daily life.',
        WellbeingBand.elevatedConcern =>
          'Please consider contacting a mental-health professional or your doctor soon. If you ever feel at risk of harming yourself, contact local emergency services or a crisis line immediately.',
      },
    );
  }
}
