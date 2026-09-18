import '../../../shared/models/hospital_model.dart';

/// Contract for hospital directory + blood availability overview.
abstract class HospitalRepository {
  Future<List<HospitalModel>> getHospitals({String? query, String? bloodGroup});

  Future<HospitalModel?> getHospitalById(String id);
}
