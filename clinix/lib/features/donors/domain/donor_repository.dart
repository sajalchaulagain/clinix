import '../../../shared/models/donor_model.dart';

/// Contract for donor directory & registration.
///
/// PRIVACY: donor contact details are never returned by this interface. The
/// backend mediates contact between requesters and donors.
abstract class DonorRepository {
  Future<List<DonorModel>> getDonors({
    String? bloodGroup,
    String? query,
    bool availableOnly,
  });

  /// Registers the current user as a donor (or updates availability).
  Future<void> becomeDonor({
    required String bloodGroup,
    required String location,
    DateTime? lastDonationDate,
    bool isAvailable,
  });

  /// Sends a contact request to a donor (backend notifies the donor).
  Future<void> requestDonorContact(String donorId, {String? note});

  /// The current user's donor profile, if registered.
  Future<DonorModel?> getMyDonorProfile();
}
