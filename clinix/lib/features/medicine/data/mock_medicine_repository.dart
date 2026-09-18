import 'package:image_picker/image_picker.dart';

import '../../../shared/models/medicine_analysis_model.dart';
import '../../../shared/models/medicine_interaction_model.dart';
import '../../../shared/models/medicine_model.dart';
import '../domain/medicine_repository.dart';

/// ⚠️ MOCK — development data for the scanner/info/comparison UI.
///
/// Returns recognizable demo analyses based on index (not image content).
/// Replace with [ApiMedicineRepository] once the FastAPI contract lands.
class MockMedicineRepository implements MedicineRepository {
  static final _catalog = <MedicineModel>[
    const MedicineModel(
      id: 'med-1',
      name: 'Paracetamol 500mg',
      genericName: 'Acetaminophen',
      manufacturer: 'Generic Health',
      category: 'Pain reliever / Fever reducer',
    ),
    const MedicineModel(
      id: 'med-2',
      name: 'Ibuprofen 400mg',
      genericName: 'Ibuprofen',
      manufacturer: 'Generic Health',
      category: 'NSAID (anti-inflammatory)',
    ),
    const MedicineModel(
      id: 'med-3',
      name: 'Cetirizine 10mg',
      genericName: 'Cetirizine hydrochloride',
      manufacturer: 'Generic Health',
      category: 'Antihistamine',
    ),
    const MedicineModel(
      id: 'med-4',
      name: 'Amoxicillin 500mg',
      genericName: 'Amoxicillin trihydrate',
      manufacturer: 'Generic Health',
      category: 'Antibiotic (penicillin class)',
    ),
  ];

  static final _analyses = <String, MedicineAnalysisModel>{
    'med-1': const MedicineAnalysisModel(
      medicineName: 'Paracetamol 500mg',
      genericName: 'Acetaminophen',
      commonUses: [
        'Relief of mild to moderate pain (headache, toothache, body ache)',
        'Reduction of fever',
      ],
      dosageInformation:
          'Typical adult dose: 500mg–1g every 4–6 hours as needed. Maximum 4g per day. Always follow the label or your pharmacist\'s advice.',
      commonSideEffects: [
        'Generally well tolerated at recommended doses',
        'Rare: skin rash or allergic reaction',
      ],
      precautions: [
        'Do not exceed the maximum daily dose',
        'Caution with liver conditions or regular alcohol use',
      ],
      warnings: [
        'Overdose can cause serious liver damage',
        'Check other products for paracetamol to avoid doubling',
      ],
      contraindications: ['Severe liver impairment'],
      interactions: [
        MedicineInteractionModel(
          interactsWith: 'Alcohol',
          severity: InteractionSeverity.moderate,
          description:
              'Regular heavy alcohol use increases liver-risk with paracetamol.',
        ),
      ],
      storageInformation: 'Store below 25°C, away from moisture and children.',
    ),
    'med-2': const MedicineAnalysisModel(
      medicineName: 'Ibuprofen 400mg',
      genericName: 'Ibuprofen',
      commonUses: [
        'Pain relief including muscular pain and period pain',
        'Reduction of inflammation and fever',
      ],
      dosageInformation:
          'Typical adult dose: 200–400mg every 4–6 hours with food. Maximum 1200mg/day without medical supervision.',
      commonSideEffects: [
        'Stomach upset or indigestion',
        'Nausea',
        'Dizziness in some people',
      ],
      precautions: [
        'Take with food or milk to protect the stomach',
        'Caution with asthma, kidney or stomach-ulcer history',
      ],
      warnings: [
        'NSAIDs can increase risk of stomach bleeding',
        'Avoid in late pregnancy unless a doctor advises',
      ],
      contraindications: [
        'Active stomach ulcer or gastrointestinal bleeding',
        'Severe kidney impairment',
      ],
      interactions: [
        MedicineInteractionModel(
          interactsWith: 'Blood thinners (e.g. warfarin)',
          severity: InteractionSeverity.severe,
          description:
              'Combining NSAIDs with anticoagulants significantly increases bleeding risk.',
        ),
        MedicineInteractionModel(
          interactsWith: 'Other NSAIDs (e.g. aspirin, diclofenac)',
          severity: InteractionSeverity.moderate,
          description: 'Taking multiple NSAIDs together raises side-effect risk.',
        ),
      ],
      storageInformation: 'Store below 30°C in the original packaging.',
    ),
    'med-3': const MedicineAnalysisModel(
      medicineName: 'Cetirizine 10mg',
      genericName: 'Cetirizine hydrochloride',
      commonUses: [
        'Relief of allergy symptoms (sneezing, runny nose, itchy eyes)',
        'Hives and itchy skin conditions',
      ],
      dosageInformation:
          'Typical adult dose: 10mg once daily. May cause drowsiness in some people.',
      commonSideEffects: [
        'Drowsiness or tiredness',
        'Dry mouth',
        'Headache',
      ],
      precautions: [
        'Avoid driving until you know how it affects you',
        'Reduce dose with kidney problems (ask a pharmacist)',
      ],
      warnings: ['Alcohol can increase drowsiness'],
      contraindications: ['Severe kidney failure (without dose adjustment)'],
      interactions: [
        MedicineInteractionModel(
          interactsWith: 'Alcohol / sedatives',
          severity: InteractionSeverity.mild,
          description: 'Can add to the drowsiness effect.',
        ),
      ],
      storageInformation: 'Store below 25°C, away from direct sunlight.',
    ),
    'med-4': const MedicineAnalysisModel(
      medicineName: 'Amoxicillin 500mg',
      genericName: 'Amoxicillin trihydrate',
      commonUses: [
        'Bacterial infections as prescribed (ear, throat, chest, dental)',
      ],
      dosageInformation:
          'Prescription-only antibiotic. Dose and duration are set by the prescriber — complete the full course.',
      commonSideEffects: [
        'Nausea or upset stomach',
        'Diarrhea',
        'Skin rash (report to a doctor, especially with allergy history)',
      ],
      precautions: [
        'Tell your prescriber about any penicillin allergy',
        'Complete the full prescribed course',
      ],
      warnings: [
        'Not effective against viral infections (cold/flu)',
        'Misuse contributes to antibiotic resistance',
      ],
      contraindications: ['Known penicillin/cephalosporin allergy'],
      interactions: [
        MedicineInteractionModel(
          interactsWith: 'Methotrexate',
          severity: InteractionSeverity.moderate,
          description: 'Amoxicillin can increase methotrexate levels.',
        ),
      ],
      storageInformation:
          'Capsules below 25°C. Syrups may need refrigeration — check the label.',
    ),
  };

  Future<void> _latency([int ms = 1600]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  @override
  Future<List<MedicineAnalysisModel>> analyzeImages(List<XFile> images) async {
    await _latency(2200);
    // Rotate through the catalog so multiple scans show different medicines.
    final analyses = _analyses.values.toList();
    return [
      for (var i = 0; i < images.length; i++) analyses[i % analyses.length],
    ];
  }

  @override
  Future<List<MedicineModel>> searchMedicines(String query) async {
    await _latency(400);
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _catalog;
    return _catalog
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            (m.genericName?.toLowerCase().contains(q) ?? false) ||
            (m.category?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Future<MedicineAnalysisModel> getMedicineInfo(String medicineId) async {
    await _latency(700);
    final analysis = _analyses[medicineId];
    if (analysis == null) {
      throw ArgumentError('Unknown medicine id: $medicineId');
    }
    return analysis;
  }

  @override
  Future<List<MedicineAnalysisModel>> compareMedicines(
    List<MedicineAnalysisModel> analyses,
  ) async {
    await _latency(500);
    return analyses;
  }
}
