import 'package:equatable/equatable.dart';

enum MentalHealthQuestionType { multipleChoice, frequencyScale, yesNo }

class MentalHealthQuestionModel extends Equatable {
  const MentalHealthQuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });

  final String id;
  final String text;
  final MentalHealthQuestionType type;

  /// Presented in order; each option maps to a 0..N score by index
  /// (matched by position with [MentalHealthAnswerModel.score]).
  final List<String> options;

  factory MentalHealthQuestionModel.fromJson(Map<String, dynamic> json) =>
      MentalHealthQuestionModel(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        type: MentalHealthQuestionType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => MentalHealthQuestionType.frequencyScale,
        ),
        options:
            (json['options'] as List? ?? []).whereType<String>().toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'options': options,
      };

  @override
  List<Object?> get props => [id];
}
