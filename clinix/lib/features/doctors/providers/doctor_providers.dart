import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_doctor_repository.dart';
import '../domain/doctor_repository.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  // BACKEND INTEGRATION: replace MockDoctorRepository with the API
  // implementation once the FastAPI contract is finalized.
  return MockDoctorRepository();
});

final recommendedDoctorsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(doctorRepositoryProvider).getRecommendedDoctors();
});

/// Search state owned by the doctors feature (query + specialty filter).
final doctorQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final doctorSpecialtyFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final filteredDoctorsProvider = FutureProvider.autoDispose((ref) {
  final query = ref.watch(doctorQueryProvider);
  final specialty = ref.watch(doctorSpecialtyFilterProvider);
  return ref
      .watch(doctorRepositoryProvider)
      .getDoctors(query: query, specialty: specialty);
});
