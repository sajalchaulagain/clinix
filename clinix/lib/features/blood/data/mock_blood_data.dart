import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../../../shared/models/donor_model.dart';
import '../../../shared/models/hospital_model.dart';

/// ⚠️ MOCK DATA STORE (development only).
///
/// One shared in-memory store so user-facing screens and the admin dashboard
/// see consistent demo data (admin edits reflect in user lists immediately).
/// All of this is replaced by real backends later:
///   * lists/searches -> FastAPI (+ maybe Firestore for public reads),
///   * writes (stock, requests) -> FastAPI only (authorized roles).
class MockBloodDataStore {
  MockBloodDataStore._();

  static final MockBloodDataStore instance = MockBloodDataStore._();

  final List<BloodStockModel> stocks = [
    BloodStockModel(
      id: 'stock-1',
      bloodGroup: 'A+',
      hospitalName: 'Nepal Mediciti Hospital',
      location: 'Lalitpur',
      unitsAvailable: 12,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      hospitalId: 'hosp-1',
    ),
    BloodStockModel(
      id: 'stock-2',
      bloodGroup: 'O+',
      hospitalName: 'Patan Hospital',
      location: 'Lalitpur',
      unitsAvailable: 4,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
      hospitalId: 'hosp-2',
    ),
    BloodStockModel(
      id: 'stock-3',
      bloodGroup: 'B-',
      hospitalName: 'T.U. Teaching Hospital',
      location: 'Kathmandu',
      unitsAvailable: 0,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      hospitalId: 'hosp-3',
    ),
    BloodStockModel(
      id: 'stock-4',
      bloodGroup: 'AB+',
      hospitalName: 'Kathmandu Model Hospital',
      location: 'Kathmandu',
      unitsAvailable: 7,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      hospitalId: 'hosp-4',
    ),
    BloodStockModel(
      id: 'stock-5',
      bloodGroup: 'O-',
      hospitalName: 'Bir Hospital',
      location: 'Kathmandu',
      unitsAvailable: 2,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 20)),
      hospitalId: 'hosp-5',
    ),
    BloodStockModel(
      id: 'stock-6',
      bloodGroup: 'B+',
      hospitalName: 'Nepal Mediciti Hospital',
      location: 'Lalitpur',
      unitsAvailable: 9,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      hospitalId: 'hosp-1',
    ),
  ];

  final List<DonorModel> donors = [
    DonorModel(
      id: 'donor-1',
      name: 'Sagar Shrestha',
      bloodGroup: 'O+',
      location: 'Kathmandu',
      isAvailable: true,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 140)),
      totalDonations: 6,
    ),
    DonorModel(
      id: 'donor-2',
      name: 'Anita Gurung',
      bloodGroup: 'A+',
      location: 'Pokhara',
      isAvailable: true,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 30)),
      totalDonations: 3,
    ),
    DonorModel(
      id: 'donor-3',
      name: 'Bikash Tamang',
      bloodGroup: 'B+',
      location: 'Lalitpur',
      isAvailable: false,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 60)),
      totalDonations: 2,
    ),
    DonorModel(
      id: 'donor-4',
      name: 'Rita Maharjan',
      bloodGroup: 'AB-',
      location: 'Bhaktapur',
      isAvailable: true,
      totalDonations: 1,
    ),
    DonorModel(
      id: 'donor-5',
      name: 'Kiran Basnet',
      bloodGroup: 'O-',
      location: 'Kathmandu',
      isAvailable: true,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 200)),
      totalDonations: 8,
    ),
  ];

  final List<HospitalModel> hospitals = [
    HospitalModel(
      id: 'hosp-1',
      name: 'Nepal Mediciti Hospital',
      location: 'Bhaisepati, Lalitpur',
      phone: '+977-1-4217766',
      isOpen24Hours: true,
      bloodUnitsByGroup: const {'A+': 12, 'B+': 9, 'O+': 3, 'AB+': 1},
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    HospitalModel(
      id: 'hosp-2',
      name: 'Patan Hospital',
      location: 'Lagankhel, Lalitpur',
      phone: '+977-1-5522295',
      isOpen24Hours: true,
      bloodUnitsByGroup: const {'O+': 4, 'A-': 2},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    HospitalModel(
      id: 'hosp-3',
      name: 'T.U. Teaching Hospital',
      location: 'Maharajgunj, Kathmandu',
      phone: '+977-1-4412404',
      bloodUnitsByGroup: const {'A+': 5, 'B-': 0, 'AB+': 3},
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    HospitalModel(
      id: 'hosp-4',
      name: 'Kathmandu Model Hospital',
      location: 'Bagbazar, Kathmandu',
      bloodUnitsByGroup: const {'AB+': 7, 'O+': 2},
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HospitalModel(
      id: 'hosp-5',
      name: 'Bir Hospital',
      location: 'New Road Gate, Kathmandu',
      isOpen24Hours: true,
      bloodUnitsByGroup: const {'O-': 2, 'A+': 6, 'B+': 4},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  final List<BloodRequestModel> requests = [
    BloodRequestModel(
      id: 'req-1',
      requesterName: 'Sunita Rai',
      bloodGroup: 'O-',
      units: 2,
      hospitalName: 'Bir Hospital',
      location: 'Kathmandu',
      status: BloodRequestStatus.pending,
      urgency: BloodRequestUrgency.urgent,
      reason: 'Scheduled surgery',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    BloodRequestModel(
      id: 'req-2',
      requesterName: 'Dipesh K.C.',
      bloodGroup: 'A+',
      units: 1,
      hospitalName: 'Patan Hospital',
      location: 'Lalitpur',
      status: BloodRequestStatus.approved,
      urgency: BloodRequestUrgency.normal,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  int _nextRequestId = 3;

  /// Demo write path for the blood request form.
  BloodRequestModel addRequest(BloodRequestModel request) {
    final stored = BloodRequestModel(
      id: 'req-${_nextRequestId++}',
      requesterName: request.requesterName,
      bloodGroup: request.bloodGroup,
      units: request.units,
      hospitalName: request.hospitalName,
      location: request.location,
      status: BloodRequestStatus.pending,
      createdAt: DateTime.now(),
      urgency: request.urgency,
      reason: request.reason,
      patientName: request.patientName,
    );
    requests.insert(0, stored);
    return stored;
  }
}
