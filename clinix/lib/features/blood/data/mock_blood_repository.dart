import '../../../shared/models/blood_donation_model.dart';
import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../domain/blood_repository.dart';
import 'mock_blood_data.dart';

/// ⚠️ MOCK — development data from [MockBloodDataStore].
class MockBloodRepository implements BloodRepository {
  MockBloodRepository([MockBloodDataStore? store])
      : _store = store ?? MockBloodDataStore.instance;

  final MockBloodDataStore _store;

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  @override
  Future<List<BloodStockModel>> getBloodStock({
    String? bloodGroup,
    String? location,
    String? hospital,
    bool availableOnly = false,
    String? query,
  }) async {
    await _latency();
    final q = query?.toLowerCase().trim() ?? '';
    return _store.stocks.where((stock) {
      if (bloodGroup != null && stock.bloodGroup != bloodGroup) return false;
      if (location != null &&
          !stock.location.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }
      if (hospital != null &&
          !stock.hospitalName.toLowerCase().contains(hospital.toLowerCase())) {
        return false;
      }
      if (availableOnly && stock.unitsAvailable <= 0) return false;
      if (q.isNotEmpty &&
          !stock.hospitalName.toLowerCase().contains(q) &&
          !stock.location.toLowerCase().contains(q) &&
          !stock.bloodGroup.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<BloodStockModel?> getStockById(String id) async {
    await _latency();
    for (final stock in _store.stocks) {
      if (stock.id == id) return stock;
    }
    return null;
  }

  @override
  Future<BloodRequestModel> submitRequest(BloodRequestModel request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return _store.addRequest(request);
  }

  @override
  Future<List<BloodRequestModel>> getMyRequests() async {
    await _latency();
    // Demo: every request in the store belongs to "this user".
    return List.unmodifiable(_store.requests);
  }

  // ---------------------------------------------------------------- donations
  @override
  Future<BloodDonationModel> submitDonationRequest(
      BloodDonationModel donation) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return _store.addDonationRequest(donation);
  }

  @override
  Future<List<BloodDonationModel>> fetchMyDonationRequests() async {
    await _latency();
    return List.unmodifiable(_store.donationRequests);
  }

  @override
  Future<BloodDonationModel> cancelDonationRequest(String id) async {
    await _latency();
    return _store.cancelDonationRequest(id);
  }
}

