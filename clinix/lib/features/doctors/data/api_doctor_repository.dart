import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/doctor_model.dart';
import '../domain/doctor_repository.dart';

/// Real doctor repository — calls FastAPI which reads Firestore.
///
/// Mirrors backend/app/api/doctor.py + backend/app/schemas/doctor.py.
class ApiDoctorRepository implements DoctorRepository {
  ApiDoctorRepository(this._factory);

  final ApiClientFactory _factory;

  @override
  Future<List<DoctorModel>> getDoctors({
    String? query,
    String? specialty,
  }) async {
    final client = await _factory.build();

    // Backend accepts: specialty (filter), location (filter), available_today.
    // 'query' does a local post-filter on name since the backend has no free-text search.
    final params = <String, dynamic>{
      if (specialty != null) 'specialty': specialty,
    };

    final response = await client.get<List<dynamic>>(
      ApiEndpoints.doctors,
      queryParameters: params.isNotEmpty ? params : null,
    );

    var doctors = (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DoctorModel.fromJson)
        .toList();

    // Client-side name search (backend has no text search endpoint yet)
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      doctors = doctors
          .where((d) =>
              d.name.toLowerCase().contains(needle) ||
              d.specialty.toLowerCase().contains(needle))
          .toList();
    }

    return doctors;
  }

  @override
  Future<List<DoctorModel>> getRecommendedDoctors({int limit = 4}) async {
    final client = await _factory.build();

    final response = await client.get<List<dynamic>>(
      ApiEndpoints.doctorsRecommended,
      queryParameters: {'limit': limit},
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DoctorModel.fromJson)
        .toList();
  }

  @override
  Future<DoctorModel?> getDoctorById(String id) async {
    final client = await _factory.build();

    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.doctorById(id),
    );

    final data = response.data;
    if (data == null) return null;
    return DoctorModel.fromJson(data);
  }
}
