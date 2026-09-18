import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/providers/api_providers.dart';
import '../data/api_doctor_repository.dart';
import '../data/mock_doctor_repository.dart';
import '../domain/doctor_repository.dart';

/// Returns the real FastAPI-backed repository when USE_MOCK_DATA=false.
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  if (!AppConfig.useMockData) {
    return ApiDoctorRepository(ref.read(apiClientProvider));
  }
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
