import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/hospital_model.dart';
import '../data/mock_hospital_repository.dart';
import '../domain/hospital_repository.dart';

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  // BACKEND INTEGRATION: replace with API implementation.
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
