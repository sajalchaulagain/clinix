import 'package:equatable/equatable.dart';

class MentalHealthAnswerModel extends Equatable {
  const MentalHealthAnswerModel({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.score,
  });

  final String questionId;
  final int selectedOptionIndex;

  /// Numeric value derived from the selected option position (0 = lowest
  /// concern). Sent to the backend for the real AI analysis.
  final int score;

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'selected_option_index': selectedOptionIndex,
        'score': score,
      };

  factory MentalHealthAnswerModel.fromJson(Map<String, dynamic> json) =>
      MentalHealthAnswerModel(
        questionId: json['question_id'] as String? ?? '',
        selectedOptionIndex: json['selected_option_index'] as int? ?? 0,
        score: json['score'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [questionId, selectedOptionIndex];
}
