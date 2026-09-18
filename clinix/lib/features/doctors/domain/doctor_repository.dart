import '../../../shared/models/doctor_model.dart';

/// Contract for doctor/healthcare-support data.
///
/// BACKEND INTEGRATION: list/search will be served by FastAPI (or Firestore
/// for public doctor profiles). The UI only knows this interface.
abstract class DoctorRepository {
  Future<List<DoctorModel>> getDoctors({String? query, String? specialty});

  Future<List<DoctorModel>> getRecommendedDoctors({int limit = 4});

  Future<DoctorModel?> getDoctorById(String id);
}
