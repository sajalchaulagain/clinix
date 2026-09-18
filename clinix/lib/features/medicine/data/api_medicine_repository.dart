import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/medicine_analysis_model.dart';
import '../../../shared/models/medicine_model.dart';
import '../domain/medicine_repository.dart';

/// Live implementation — uploads images (multipart) to FastAPI which uses
/// OpenRouter vision + openFDA to produce a structured [MedicineAnalysisModel].
///
/// Mirrors backend/app/api/medicine.py + backend/app/schemas/medicine.py.
class ApiMedicineRepository implements MedicineRepository {
  ApiMedicineRepository(this._factory);

  final ApiClientFactory _factory;

  @override
  Future<List<MedicineAnalysisModel>> analyzeImages(List<XFile> images) async {
    final client = await _factory.build();

    // Multipart upload — ApiClient.uploadImages builds FormData.
    // The backend (medicine.py) returns list[MedicineAnalysis] as a JSON array.
    final response = await client.uploadImages<List<dynamic>>(
      ApiEndpoints.medicineAnalyze,
      images: images,
      fieldName: 'images',
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MedicineAnalysisModel.fromJson)
        .toList();
  }

  @override
  Future<List<MedicineModel>> searchMedicines(String query) async {
    if (query.trim().isEmpty) return [];
    final client = await _factory.build();

    final response = await client.get<List<dynamic>>(
      ApiEndpoints.medicineSearch,
      queryParameters: {'query': query.trim()},
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MedicineModel.fromJson)
        .toList();
  }

  @override
  Future<MedicineAnalysisModel> getMedicineInfo(String medicineId) async {
    final client = await _factory.build();

    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.medicineInfo,
      queryParameters: {'name': medicineId},
    );

    final data = response.data;
    if (data == null) throw ArgumentError('Medicine not found: $medicineId');
    return MedicineAnalysisModel.fromJson(data);
  }

  @override
  Future<List<MedicineAnalysisModel>> compareMedicines(
    List<MedicineAnalysisModel> analyses,
  ) async {
    final client = await _factory.build();

    final response = await client.post<List<dynamic>>(
      ApiEndpoints.medicineCompare,
      data: {'analyses': analyses.map((a) => a.toJson()).toList()},
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MedicineAnalysisModel.fromJson)
        .toList();
  }
}
