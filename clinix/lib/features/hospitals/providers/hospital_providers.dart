import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/hospital_model.dart';
import '../data/api_hospital_repository.dart';
import '../data/mock_hospital_repository.dart';
import '../domain/hospital_repository.dart';

/// Returns the real FastAPI-backed repository when USE_MOCK_DATA=false.
final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  if (!AppConfig.useMockData) {
    return ApiHospitalRepository(ref.read(apiClientProvider));
  }
  return MockHospitalRepository();
});

final hospitalSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');
final hospitalBloodGroupFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final filteredHospitalsProvider =
    FutureProvider.autoDispose<List<HospitalModel>>((ref) {
  final query = ref.watch(hospitalSearchQueryProvider);
  final group = ref.watch(hospitalBloodGroupFilterProvider);
  return ref
      .watch(hospitalRepositoryProvider)
      .getHospitals(query: query, bloodGroup: group);
});
