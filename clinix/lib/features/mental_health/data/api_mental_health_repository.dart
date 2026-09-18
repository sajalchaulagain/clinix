import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/mental_health_answer_model.dart';
import '../../../shared/models/mental_health_question_model.dart';
import '../../../shared/models/mental_health_result_model.dart';
import '../domain/mental_health_repository.dart';

/// Real mental health repository — POSTs screening answers to FastAPI which
/// uses OpenRouter to produce a non-diagnostic [MentalHealthResultModel].
///
/// Mirrors backend/app/api/mental_health.py + backend/app/schemas/mental_health.py.
class ApiMentalHealthRepository implements MentalHealthRepository {
  ApiMentalHealthRepository(this._factory);

  final ApiClientFactory _factory;

  // Static question list — lives on the client so it can be updated without a
  // backend deploy. Question text is also sent to the backend as context so the
  // AI can generate more relevant narrative observations.
  static final List<MentalHealthQuestionModel> _questions = [
    const MentalHealthQuestionModel(
      id: 'mh-1',
      text: 'Over the last two weeks, how often have you felt little interest '
          'or pleasure in doing things?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-2',
      text: 'How often have you felt down, depressed, or hopeless?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-3',
      text: 'How often have you had trouble falling or staying asleep, '
          'or sleeping too much?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-4',
      text: 'How often have you felt tired or had little energy?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-5',
      text: 'How often have you felt nervous, anxious, or on edge?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-6',
      text: 'How often have you been unable to stop or control worrying?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-7',
      text: 'How often have you had trouble concentrating on things like '
          'reading or watching TV?',
      type: MentalHealthQuestionType.frequencyScale,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-8',
      text: 'Do you feel connected to supportive friends or family?',
      type: MentalHealthQuestionType.yesNo,
      options: ['Yes', 'Sometimes', 'No'],
    ),
    const MentalHealthQuestionModel(
      id: 'mh-9',
      text: 'How often do you make time for activities that recharge you '
          '(walks, hobbies, rest)?',
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
    // Questions are static — no network call needed.
    return _questions;
  }

  @override
  Future<MentalHealthResultModel> analyze(
    List<MentalHealthAnswerModel> answers,
  ) async {
    final client = await _factory.build();

    // Serialize answers using the model's toJson() helper.
    final answersJson = answers.map((a) => a.toJson()).toList();

    // Provide question texts as context so the backend AI narrative
    // can reference the actual question wording.
    final questionsJson = _questions
        .map(
          (q) => {
            'id': q.id,
            'text': q.text,
            'options': q.options,
          },
        )
        .toList();

    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.mentalHealthAnalyze,
      data: {
        'answers': answersJson,
        'questions': questionsJson,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from mental health service.');
    }
    return MentalHealthResultModel.fromJson(data);
  }
}
