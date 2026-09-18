import 'package:equatable/equatable.dart';

enum InteractionSeverity { mild, moderate, severe }

class MedicineInteractionModel extends Equatable {
  const MedicineInteractionModel({
    required this.interactsWith,
    required this.severity,
    required this.description,
  });

  final String interactsWith;
  final InteractionSeverity severity;
  final String description;

  static InteractionSeverity _severityFromJson(String? value) {
    return InteractionSeverity.values.firstWhere(
      (s) => s.name == value,
      orElse: () => InteractionSeverity.mild,
    );
  }

  factory MedicineInteractionModel.fromJson(Map<String, dynamic> json) =>
      MedicineInteractionModel(
        interactsWith: json['interacts_with'] as String? ?? '',
        severity: _severityFromJson(json['severity'] as String?),
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'interacts_with': interactsWith,
        'severity': severity.name,
        'description': description,
      };

  @override
  List<Object?> get props => [interactsWith, severity];
}
