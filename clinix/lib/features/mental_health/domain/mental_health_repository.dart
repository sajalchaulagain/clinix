import '../../../shared/models/mental_health_answer_model.dart';
import '../../../shared/models/mental_health_question_model.dart';
import '../../../shared/models/mental_health_result_model.dart';

/// Contract for the mental-health screening feature.
///
/// BACKEND INTEGRATION: answers will be POSTed to FastAPI for AI-assisted
/// analysis (see ApiEndpoints.mentalHealthAnalyze). The response is a
/// [MentalHealthResultModel] — the result UI consumes exactly this model, so
/// swapping implementations requires no UI change.
abstract class MentalHealthRepository {
  Future<List<MentalHealthQuestionModel>> getQuestions();

  /// Submits answers and returns a SCREENING SUMMARY (never a diagnosis).
  Future<MentalHealthResultModel> analyze(
    List<MentalHealthAnswerModel> answers,
  );
}
