import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/donor_model.dart';
import '../domain/donor_repository.dart';

/// Real donor repository — calls FastAPI.
/// Donor contact details are NEVER returned to the client (privacy rule).
/// Contact requests are mediated server-side.
///
/// Mirrors backend/app/api/donor.py + backend/app/schemas/donor.py.
class ApiDonorRepository implements DonorRepository {
  ApiDonorRepository(this._factory);

  final ApiClientFactory _factory;

  @override
  Future<List<DonorModel>> getDonors({
    String? bloodGroup,
    String? query,
    bool availableOnly = false,
  }) async {
    final client = await _factory.build();

    final params = <String, dynamic>{
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (availableOnly) 'available_only': true,
      if (query != null && query.isNotEmpty) 'q': query,
    };

    final response = await client.get<List<dynamic>>(
      ApiEndpoints.donors,
      queryParameters: params.isNotEmpty ? params : null,
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DonorModel.fromJson)
        .toList();
  }

  @override
  Future<void> becomeDonor({
    required String bloodGroup,
    required String location,
    DateTime? lastDonationDate,
    bool isAvailable = true,
  }) async {
    final client = await _factory.build();

    await client.post<Map<String, dynamic>>(
      ApiEndpoints.donors,
      data: {
        'blood_group': bloodGroup,
        'location': location,
        'is_available': isAvailable,
        if (lastDonationDate != null)
          'last_donation_date': lastDonationDate.toIso8601String(),
      },
    );
  }

  @override
  Future<void> requestDonorContact(String donorId, {String? note}) async {
    final client = await _factory.build();

    await client.post<Map<String, dynamic>>(
      ApiEndpoints.donorContact(donorId),
      data: {
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
  }

  @override
  Future<DonorModel?> getMyDonorProfile() async {
    final client = await _factory.build();

    try {
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.donorMe,
      );
      final data = response.data;
      if (data == null) return null;
      return DonorModel.fromJson(data);
    } catch (_) {
      // 404 means the user is not registered as a donor yet — that's expected.
      return null;
    }
  }
}
