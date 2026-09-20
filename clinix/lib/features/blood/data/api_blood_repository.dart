import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/blood_donation_model.dart';
import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../domain/blood_repository.dart';

/// Real blood repository — calls FastAPI which reads/writes Firestore
/// via the Firebase Admin SDK (server-side only).
///
/// Mirrors backend/app/api/blood.py + backend/app/schemas/blood.py.
class ApiBloodRepository implements BloodRepository {
  ApiBloodRepository(this._factory);

  final ApiClientFactory _factory;

  @override
  Future<List<BloodStockModel>> getBloodStock({
    String? bloodGroup,
    String? location,
    String? hospital,
    bool availableOnly = false,
    String? query,
  }) async {
    final client = await _factory.build();

    final params = <String, dynamic>{
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (location != null) 'location': location,
      if (availableOnly) 'low_stock': false, // backend filter: available only
    };

    // Client-side hospital/query filter applied after fetch because
    // the backend doesn't expose a combined search endpoint yet.
    final response = await client.get<List<dynamic>>(
      ApiEndpoints.bloodStock,
      queryParameters: params.isNotEmpty ? params : null,
    );

    var items = (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(BloodStockModel.fromJson)
        .toList();

    // Post-filter: hospital name (partial, case-insensitive)
    if (hospital != null && hospital.isNotEmpty) {
      final needle = hospital.toLowerCase();
      items = items
          .where((s) => s.hospitalName.toLowerCase().contains(needle))
          .toList();
    }

    // Post-filter: generic query (blood group OR hospital OR location)
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      items = items.where((s) {
        return s.bloodGroup.toLowerCase().contains(needle) ||
            s.hospitalName.toLowerCase().contains(needle) ||
            s.location.toLowerCase().contains(needle);
      }).toList();
    }

    // Post-filter: available-only (units > 0)
    if (availableOnly) {
      items = items.where((s) => s.unitsAvailable > 0).toList();
    }

    return items;
  }

  @override
  Future<BloodStockModel?> getStockById(String id) async {
    final client = await _factory.build();

    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.bloodStockById(id),
    );

    final data = response.data;
    if (data == null) return null;
    return BloodStockModel.fromJson(data);
  }

  @override
  Future<BloodRequestModel> submitRequest(BloodRequestModel request) async {
    final client = await _factory.build();

    // Backend creates the request and returns the persisted record (with
    // server-assigned id and created_at).
    final body = {
      'blood_group': request.bloodGroup,
      'units': request.units,
      'hospital_name': request.hospitalName,
      'location': request.location,
      'urgency': request.urgency.name,
      if (request.reason != null) 'reason': request.reason,
      if (request.patientName != null) 'patient_name': request.patientName,
    };

    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.bloodRequests,
      data: body,
    );

    final data = response.data;
    if (data == null) throw const FormatException('Empty response from server.');
    return BloodRequestModel.fromJson(data);
  }

  @override
  Future<List<BloodRequestModel>> getMyRequests() async {
    final client = await _factory.build();

    final response = await client.get<List<dynamic>>(
      ApiEndpoints.bloodRequestsMy,
    );

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(BloodRequestModel.fromJson)
        .toList();
  }

  // ---------------------------------------------------------------- donations
  @override
  Future<BloodDonationModel> submitDonationRequest(
      BloodDonationModel donation) async {
    final client = await _factory.build();
    final body = {
      'donor_name': donation.donorName,
      'phone': donation.phone,
      'blood_group': donation.bloodGroup,
      'units': donation.units,
      'hospital_name': donation.hospitalName,
      'location': donation.location,
      if (donation.preferredDate != null)
        'preferred_date':
            donation.preferredDate!.toIso8601String().substring(0, 10),
      if (donation.notes != null && donation.notes!.isNotEmpty)
        'notes': donation.notes,
    };
    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.bloodDonationRequests,
      data: body,
    );
    final data = response.data;
    if (data == null) throw const FormatException('Empty response from server.');
    return BloodDonationModel.fromJson(data);
  }

  @override
  Future<List<BloodDonationModel>> fetchMyDonationRequests() async {
    final client = await _factory.build();
    final response = await client.get<List<dynamic>>(
      ApiEndpoints.bloodDonationRequestsMy,
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(BloodDonationModel.fromJson)
        .toList();
  }

  @override
  Future<BloodDonationModel> cancelDonationRequest(String id) async {
    final client = await _factory.build();
    final response = await client.put<Map<String, dynamic>>(
      ApiEndpoints.bloodDonationRequestCancel(id),
    );
    final data = response.data;
    if (data == null) throw const FormatException('Empty response from server.');
    return BloodDonationModel.fromJson(data);
  }
}

