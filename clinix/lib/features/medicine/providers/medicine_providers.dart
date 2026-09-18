import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/config/app_config.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/medicine_analysis_model.dart';
import '../../../shared/models/medicine_model.dart';
import '../data/api_medicine_repository.dart';
import '../data/mock_medicine_repository.dart';
import '../domain/medicine_repository.dart';

/// Returns the real FastAPI-backed repository when USE_MOCK_DATA=false.
final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  if (!AppConfig.useMockData) {
    return ApiMedicineRepository(ref.read(apiClientProvider));
  }
  return MockMedicineRepository();
});

/// Images currently selected in the scanner (kept as XFile so the same
/// objects can be handed to the multipart uploader later).
class SelectedImagesNotifier extends AutoDisposeNotifier<List<XFile>> {
  @override
  List<XFile> build() => [];

  void addAll(List<XFile> images) {
    // Cap at 4 images — keeps the demo focused and mirrors the future
    // backend upload limit.
    final combined = [...state, ...images];
    state = combined.take(4).toList();
  }

  void removeAt(int index) {
    state = [...state]..removeAt(index);
  }

  void clear() => state = [];
}

final selectedImagesProvider =
    AutoDisposeNotifierProvider<SelectedImagesNotifier, List<XFile>>(
  SelectedImagesNotifier.new,
);

/// Analysis runs for the scanner's "Analyze" button.
/// `null` = not started; AsyncLoading = processing; AsyncData = results.
class ScanAnalysisController
    extends AutoDisposeNotifier<AsyncValue<List<MedicineAnalysisModel>>?> {
  @override
  AsyncValue<List<MedicineAnalysisModel>>? build() => null;

  Future<void> analyze(List<XFile> images) async {
    state = const AsyncLoading();
    try {
      final results = await ref.read(medicineRepositoryProvider).analyzeImages(images);
      state = AsyncData(results);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  void reset() => state = null;
}

final scanAnalysisProvider = AutoDisposeNotifierProvider<ScanAnalysisController,
    AsyncValue<List<MedicineAnalysisModel>>?>(ScanAnalysisController.new);

/// Medicine guide search (Medicine Info screen).
final medicineSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

final medicineSearchResultsProvider =
    FutureProvider.autoDispose<List<MedicineModel>>((ref) {
  final query = ref.watch(medicineSearchQueryProvider);
  return ref.watch(medicineRepositoryProvider).searchMedicines(query);
});

final medicineInfoProvider = FutureProvider.autoDispose
    .family<MedicineAnalysisModel, String>((ref, medicineId) {
  return ref.watch(medicineRepositoryProvider).getMedicineInfo(medicineId);
});
