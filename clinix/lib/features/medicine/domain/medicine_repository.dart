import 'package:image_picker/image_picker.dart';

import '../../../shared/models/medicine_analysis_model.dart';
import '../../../shared/models/medicine_model.dart';

/// Contract for medicine-related features.
///
/// SECURITY: the real implementation uploads images to FastAPI
/// (multipart via ApiClient.uploadImages). OpenRouter/openFDA/RxNorm are
/// accessed ONLY by the backend — never from this app, and no API keys ever
/// exist in the Flutter codebase.
abstract class MedicineRepository {
  /// Analyzes one or more photographed medicine packages/labels.
  Future<List<MedicineAnalysisModel>> analyzeImages(List<XFile> images);

  /// Searches the medicine guide by name.
  Future<List<MedicineModel>> searchMedicines(String query);

  /// Detailed information for one medicine.
  Future<MedicineAnalysisModel> getMedicineInfo(String medicineId);

  /// Structured side-by-side comparison for multiple analyses.
  /// (The UI already has both analyses; the backend may enrich this later.)
  Future<List<MedicineAnalysisModel>> compareMedicines(
    List<MedicineAnalysisModel> analyses,
  );
}
