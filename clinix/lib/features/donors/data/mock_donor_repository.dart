import '../../../shared/models/donor_model.dart';
import '../../blood/data/mock_blood_data.dart';
import '../domain/donor_repository.dart';

/// ⚠️ MOCK — development data from the shared [MockBloodDataStore].
class MockDonorRepository implements DonorRepository {
  MockDonorRepository([MockBloodDataStore? store])
      : _store = store ?? MockBloodDataStore.instance;

  final MockBloodDataStore _store;
  DonorModel? _myProfile;

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  @override
  Future<List<DonorModel>> getDonors({
    String? bloodGroup,
    String? query,
    bool availableOnly = false,
  }) async {
    await _latency();
    final q = query?.toLowerCase().trim() ?? '';
    return _store.donors.where((donor) {
      if (bloodGroup != null && donor.bloodGroup != bloodGroup) return false;
      if (availableOnly && !donor.isAvailable) return false;
      if (q.isNotEmpty &&
          !donor.name.toLowerCase().contains(q) &&
          !donor.location.toLowerCase().contains(q) &&
          !donor.bloodGroup.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> becomeDonor({
    required String bloodGroup,
    required String location,
    DateTime? lastDonationDate,
    bool isAvailable = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final profile = DonorModel(
      id: 'donor-me',
      name: 'You',
      bloodGroup: bloodGroup,
      location: location,
      isAvailable: isAvailable,
      lastDonationDate: lastDonationDate,
      totalDonations: lastDonationDate != null ? 1 : 0,
    );
    _myProfile = profile;
    // Reflect in the shared demo directory too.
    _store.donors.removeWhere((d) => d.id == 'donor-me');
    _store.donors.insert(0, profile);
  }

  @override
  Future<void> requestDonorContact(String donorId, {String? note}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // Backend phase: creates a mediated contact request + notification.
  }

  @override
  Future<DonorModel?> getMyDonorProfile() async {
    await _latency();
    return _myProfile;
  }
}
