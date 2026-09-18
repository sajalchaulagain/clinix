import '../../../shared/models/hospital_model.dart';
import '../../blood/data/mock_blood_data.dart';
import '../domain/hospital_repository.dart';

/// ⚠️ MOCK — development data from the shared [MockBloodDataStore].
class MockHospitalRepository implements HospitalRepository {
  MockHospitalRepository([MockBloodDataStore? store])
      : _store = store ?? MockBloodDataStore.instance;

  final MockBloodDataStore _store;

  @override
  Future<List<HospitalModel>> getHospitals({
    String? query,
    String? bloodGroup,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final q = query?.toLowerCase().trim() ?? '';
    return _store.hospitals.where((hospital) {
      if (q.isNotEmpty &&
          !hospital.name.toLowerCase().contains(q) &&
          !hospital.location.toLowerCase().contains(q)) {
        return false;
      }
      if (bloodGroup != null) {
        final units = hospital.bloodUnitsByGroup[bloodGroup] ?? 0;
        if (units <= 0) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<HospitalModel?> getHospitalById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final hospital in _store.hospitals) {
      if (hospital.id == id) return hospital;
    }
    return null;
  }
}
