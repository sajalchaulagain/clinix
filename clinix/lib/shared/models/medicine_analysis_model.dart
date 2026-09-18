import 'package:equatable/equatable.dart';

import 'medicine_interaction_model.dart';

/// Result of analyzing a scanned medicine image.
///
/// BACKEND INTEGRATION: produced by FastAPI (OpenRouter vision + openFDA +
/// RxNorm). Every field is a List<String>/String so the UI can render sections
/// generically with [sections]. `isAiGenerated` drives the mandatory safety
/// labeling in the result UI.
class MedicineAnalysisModel extends Equatable {
  const MedicineAnalysisModel({
    required this.medicineName,
    this.genericName,
    this.commonUses = const [],
    this.dosageInformation,
    this.commonSideEffects = const [],
    this.precautions = const [],
    this.warnings = const [],
    this.contraindications = const [],
    this.interactions = const [],
    this.storageInformation,
    this.isAiGenerated = true,
  });

  final String medicineName;
  final String? genericName;
  final List<String> commonUses;
  final String? dosageInformation;
  final List<String> commonSideEffects;
  final List<String> precautions;
  final List<String> warnings;
  final List<String> contraindications;
  final List<MedicineInteractionModel> interactions;
  final String? storageInformation;
  final bool isAiGenerated;

  /// Section map so the result UI renders generically instead of hardcoding
  /// each field — new sections from the backend appear automatically.
  Map<String, List<String>> get sections => {
        'Common Uses': commonUses,
        'Common Side Effects': commonSideEffects,
        'Precautions': precautions,
        'Warnings': warnings,
        'Contraindications': contraindications,
        'Drug Interactions': interactions.map((i) => i.description).toList(),
        if (storageInformation != null) 'Storage': [storageInformation!],
      };

  factory MedicineAnalysisModel.fromJson(Map<String, dynamic> json) =>
      MedicineAnalysisModel(
        medicineName: json['medicine_name'] as String? ?? 'Unknown medicine',
        genericName: json['generic_name'] as String?,
        commonUses: _stringList(json['common_uses']),
        dosageInformation: json['dosage_information'] as String?,
        commonSideEffects: _stringList(json['common_side_effects']),
        precautions: _stringList(json['precautions']),
        warnings: _stringList(json['warnings']),
        contraindications: _stringList(json['contraindications']),
        interactions: (json['interactions'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MedicineInteractionModel.fromJson)
            .toList(),
        storageInformation: json['storage_information'] as String?,
        isAiGenerated: json['is_ai_generated'] as bool? ?? true,
      );

  static List<String> _stringList(dynamic value) =>
      (value as List? ?? []).whereType<String>().toList();

  Map<String, dynamic> toJson() => {
        'medicine_name': medicineName,
        'generic_name': genericName,
        'common_uses': commonUses,
        'dosage_information': dosageInformation,
        'common_side_effects': commonSideEffects,
        'precautions': precautions,
        'warnings': warnings,
        'contraindications': contraindications,
        'interactions': interactions.map((i) => i.toJson()).toList(),
        'storage_information': storageInformation,
        'is_ai_generated': isAiGenerated,
      };

  @override
  List<Object?> get props => [medicineName, genericName];
}
