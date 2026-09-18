import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/hospital_model.dart';
import '../domain/hospital_repository.dart';

/// Real hospital repository — calls FastAPI which reads Firestore.
///
/// Mirrors backend/app/api/hospital.py + backend/app/schemas/hospital.py.
class ApiHospitalRepository implements HospitalRepository {
  ApiHospitalRepository(this._factory);

  final ApiClientFactory _factory;

  @override
  Future<List<HospitalModel>> getHospitals({
    String? query,
    String? bloodGroup,
  }) async {
    final client = await _factory.build();

    // Backend only supports 'location' filter; blood_group + text search
    // are done client-side.
    final params = <String, dynamic>{};

    final response = await client.get<List<dynamic>>(
      ApiEndpoints.hospitals,
      queryParameters: params.isNotEmpty ? params : null,
    );

    var hospitals = (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(HospitalModel.fromJson)
        .toList();

    // Client-side text search (name or location)
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      hospitals = hospitals
          .where((h) =>
              h.name.toLowerCase().contains(needle) ||
              h.location.toLowerCase().contains(needle))
          .toList();
    }

    // Client-side blood group filter
    if (bloodGroup != null) {
      hospitals = hospitals
          .where((h) => h.bloodUnitsByGroup.containsKey(bloodGroup))
          .toList();
    }

    return hospitals;
  }

  @override
  Future<HospitalModel?> getHospitalById(String id) async {
    final client = await _factory.build();

    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.hospitalById(id),
    );

    final data = response.data;
    if (data == null) return null;
    return HospitalModel.fromJson(data);
  }
}
