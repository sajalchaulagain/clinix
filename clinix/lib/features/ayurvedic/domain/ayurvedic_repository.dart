import 'package:equatable/equatable.dart';

/// A traditional Ayurvedic remedy/wellness card.
class AyurvedicRemedyModel extends Equatable {
  const AyurvedicRemedyModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.traditionalUse,
    required this.precautions,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String traditionalUse;
  final String precautions;

  factory AyurvedicRemedyModel.fromJson(Map<String, dynamic> json) =>
      AyurvedicRemedyModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        traditionalUse: json['traditional_use'] as String? ?? '',
        precautions: json['precautions'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'traditional_use': traditionalUse,
        'precautions': precautions,
      };

  @override
  List<Object?> get props => [id];
}

/// Contract for Baidyek Sathi content. The chat itself reuses [AiRepository]
/// with the baidyek persona.
abstract class AyurvedicRepository {
  /// Traditional suggestions for free-text symptoms (informational).
  Future<List<AyurvedicRemedyModel>> suggestForSymptoms(String symptoms);

  Future<List<AyurvedicRemedyModel>> remediesForCategory(String category);
}
