import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../../../shared/models/donor_model.dart';
import '../../../shared/models/hospital_model.dart';
import '../../../shared/models/user_model.dart';
import '../../blood/data/mock_blood_data.dart';
import '../domain/admin_repository.dart';

/// ⚠️ MOCK — admin demo operating on the shared [MockBloodDataStore], so
/// admin edits are instantly visible on user-facing screens.
class MockAdminRepository implements AdminRepository {
  MockAdminRepository([MockBloodDataStore? store])
      : _store = store ?? MockBloodDataStore.instance;

  final MockBloodDataStore _store;

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<AdminStats> getStats() async {
    await _latency();
    return AdminStats(
      totalDonors: _store.donors.length,
      availableBloodUnits:
          _store.stocks.fold(0, (sum, s) => sum + s.unitsAvailable),
      totalBloodRequests: _store.requests.length,
      registeredHospitals: _store.hospitals.length,
      pendingRequests: _store.requests
          .where((r) => r.status == BloodRequestStatus.pending)
          .length,
      totalUsers: 128, // static demo number
    );
  }

  @override
  Future<List<BloodStockModel>> getInventory() async {
    await _latency();
    return List.unmodifiable(_store.stocks);
  }

  @override
  Future<BloodStockModel> upsertStock(BloodStockModel stock) async {
    await _latency();
    final index = _store.stocks.indexWhere((s) => s.id == stock.id);
    final stored = index >= 0
        ? stock.copyWith(lastUpdated: DateTime.now())
        : BloodStockModel(
            id: 'stock-${DateTime.now().millisecondsSinceEpoch}',
            bloodGroup: stock.bloodGroup,
            hospitalName: stock.hospitalName,
            location: stock.location,
            unitsAvailable: stock.unitsAvailable,
            lastUpdated: DateTime.now(),
            hospitalId: stock.hospitalId,
          );
    if (index >= 0) {
      _store.stocks[index] = stored;
    } else {
      _store.stocks.add(stored);
    }
    return stored;
  }

  @override
  Future<void> deleteStock(String stockId) async {
    await _latency();
    _store.stocks.removeWhere((s) => s.id == stockId);
  }

  @override
  Future<List<BloodRequestModel>> getRequests() async {
    await _latency();
    return List.unmodifiable(_store.requests);
  }

  @override
  Future<void> updateRequestStatus(
    String requestId,
    BloodRequestStatus status,
  ) async {
    await _latency();
    final index = _store.requests.indexWhere((r) => r.id == requestId);
    if (index < 0) return;
    final current = _store.requests[index];
    _store.requests[index] = BloodRequestModel(
      id: current.id,
      requesterName: current.requesterName,
      bloodGroup: current.bloodGroup,
      units: current.units,
      hospitalName: current.hospitalName,
      location: current.location,
      status: status,
      createdAt: current.createdAt,
      urgency: current.urgency,
      reason: current.reason,
      patientName: current.patientName,
    );
  }

  @override
  Future<List<DonorModel>> getDonors() async {
    await _latency();
    return List.unmodifiable(_store.donors);
  }

  @override
  Future<void> removeDonor(String donorId) async {
    await _latency();
    _store.donors.removeWhere((d) => d.id == donorId);
  }

  @override
  Future<List<HospitalModel>> getHospitals() async {
    await _latency();
    return List.unmodifiable(_store.hospitals);
  }

  @override
  Future<List<UserModel>> getUsers() async {
    await _latency();
    return const [
      UserModel(
        id: 'u-1',
        fullName: 'Aarav Karki',
        email: 'aarav@example.com',
        role: UserRole.patient,
        bloodGroup: 'B+',
      ),
      UserModel(
        id: 'u-2',
        fullName: 'Maya Poudel',
        email: 'maya@example.com',
        role: UserRole.patient,
        bloodGroup: 'O+',
      ),
      UserModel(
        id: 'u-3',
        fullName: 'Hospital Admin',
        email: 'admin@clinix.app',
        role: UserRole.admin,
      ),
    ];
  }

  @override
  Future<void> broadcastNotification(String title, String body) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Backend phase: FastAPI -> FCM topic broadcast.
  }
}
