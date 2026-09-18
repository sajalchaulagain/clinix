import '../../../shared/models/doctor_model.dart';
import '../domain/doctor_repository.dart';

/// ⚠️ MOCK — development data. Replace with Api/Firebase implementation.
class MockDoctorRepository implements DoctorRepository {
  static final List<DoctorModel> _doctors = [
    const DoctorModel(
      id: 'doc-1',
      name: 'Dr. Anjali Sharma',
      specialty: 'Cardiologist',
      hospitalName: 'Nepal Mediciti Hospital',
      location: 'Lalitpur',
      rating: 4.8,
      yearsExperience: 12,
      consultationFee: 1500,
      isAvailableToday: true,
      bio: 'Specialises in preventive cardiology and hypertension management.',
    ),
    const DoctorModel(
      id: 'doc-2',
      name: 'Dr. Bishal Thapa',
      specialty: 'General Physician',
      hospitalName: 'Patan Hospital',
      location: 'Lalitpur',
      rating: 4.6,
      yearsExperience: 8,
      consultationFee: 1000,
      isAvailableToday: true,
      bio: 'General medicine with a focus on primary care and diagnostics.',
    ),
    const DoctorModel(
      id: 'doc-3',
      name: 'Dr. Sunita Karki',
      specialty: 'Dermatologist',
      hospitalName: 'Kathmandu Model Hospital',
      location: 'Kathmandu',
      rating: 4.7,
      yearsExperience: 10,
      consultationFee: 1200,
      isAvailableToday: false,
    ),
    const DoctorModel(
      id: 'doc-4',
      name: 'Dr. Rohan Adhikari',
      specialty: 'Pediatrician',
      hospitalName: 'Kanti Children\'s Hospital',
      location: 'Kathmandu',
      rating: 4.9,
      yearsExperience: 15,
      consultationFee: 1400,
      isAvailableToday: true,
    ),
    const DoctorModel(
      id: 'doc-5',
      name: 'Dr. Prerana Singh',
      specialty: 'Psychiatrist',
      hospitalName: 'T.U. Teaching Hospital',
      location: 'Kathmandu',
      rating: 4.8,
      yearsExperience: 11,
      consultationFee: 2000,
      isAvailableToday: false,
      bio: 'Mental health, anxiety and mood disorders.',
    ),
  ];

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<DoctorModel>> getDoctors({
    String? query,
    String? specialty,
  }) async {
    await _latency();
    final q = query?.toLowerCase().trim() ?? '';
    return _doctors.where((doctor) {
      final matchesQuery = q.isEmpty ||
          doctor.name.toLowerCase().contains(q) ||
          doctor.specialty.toLowerCase().contains(q) ||
          doctor.location.toLowerCase().contains(q);
      final matchesSpecialty = specialty == null ||
          specialty.isEmpty ||
          doctor.specialty == specialty;
      return matchesQuery && matchesSpecialty;
    }).toList();
  }

  @override
  Future<List<DoctorModel>> getRecommendedDoctors({int limit = 4}) async {
    await _latency();
    final sorted = [..._doctors]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  @override
  Future<DoctorModel?> getDoctorById(String id) async {
    await _latency();
    for (final doctor in _doctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }
}
