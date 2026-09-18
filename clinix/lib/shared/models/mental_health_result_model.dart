import 'package:equatable/equatable.dart';

/// Screening SUMMARY — never a diagnosis.
///
/// The wording of every field is intentionally non-diagnostic. The real
/// analysis will be produced by the FastAPI backend (AI-assisted) and consumed
/// through this exact model so the result UI doesn't change.
enum WellbeingBand { stable, mildConcern, elevatedConcern }

class MentalHealthResultModel extends Equatable {
  const MentalHealthResultModel({
    required this.band,
    required this.summary,
    required this.observations,
    required this.copingSuggestions,
    required this.lifestyleSuggestions,
    required this.seekHelpGuidance,
    this.totalScore = 0,
    this.maxScore = 0,
    this.isAiGenerated = true,
  });

  final WellbeingBand band;
  final String summary;
  final List<String> observations;
  final List<String> copingSuggestions;
  final List<String> lifestyleSuggestions;
  final String seekHelpGuidance;
  final int totalScore;
  final int maxScore;
  final bool isAiGenerated;

  /// Friendly, non-clinical label shown in the UI.
  String get bandLabel => switch (band) {
        WellbeingBand.stable => 'Generally stable',
        WellbeingBand.mildConcern => 'Some areas to watch',
        WellbeingBand.elevatedConcern => 'Elevated concern indicators',
      };

  factory MentalHealthResultModel.fromJson(Map<String, dynamic> json) =>
      MentalHealthResultModel(
        band: WellbeingBand.values.firstWhere(
          (b) => b.name == json['band'],
          orElse: () => WellbeingBand.stable,
        ),
        summary: json['summary'] as String? ?? '',
        observations: _list(json['observations']),
        copingSuggestions: _list(json['coping_suggestions']),
        lifestyleSuggestions: _list(json['lifestyle_suggestions']),
        seekHelpGuidance: json['seek_help_guidance'] as String? ?? '',
        totalScore: json['total_score'] as int? ?? 0,
        maxScore: json['max_score'] as int? ?? 0,
        isAiGenerated: json['is_ai_generated'] as bool? ?? true,
      );

  static List<String> _list(dynamic value) =>
      (value as List? ?? []).whereType<String>().toList();

  Map<String, dynamic> toJson() => {
        'band': band.name,
        'summary': summary,
        'observations': observations,
        'coping_suggestions': copingSuggestions,
        'lifestyle_suggestions': lifestyleSuggestions,
        'seek_help_guidance': seekHelpGuidance,
        'total_score': totalScore,
        'max_score': maxScore,
        'is_ai_generated': isAiGenerated,
      };

  @override
  List<Object?> get props => [band, totalScore];
}
