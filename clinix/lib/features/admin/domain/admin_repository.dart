import 'package:equatable/equatable.dart';

import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../../../shared/models/donor_model.dart';
import '../../../shared/models/hospital_model.dart';
import '../../../shared/models/user_model.dart';

/// Aggregated stats for the admin dashboard.
class AdminStats extends Equatable {
  const AdminStats({
    required this.totalDonors,
    required this.availableBloodUnits,
    required this.totalBloodRequests,
    required this.registeredHospitals,
    required this.pendingRequests,
    required this.totalUsers,
  });

  final int totalDonors;
  final int availableBloodUnits;
  final int totalBloodRequests;
  final int registeredHospitals;
  final int pendingRequests;
  final int totalUsers;

  @override
  List<Object?> get props => [
        totalDonors,
        availableBloodUnits,
        totalBloodRequests,
        registeredHospitals,
        pendingRequests,
        totalUsers,
      ];
}

/// Contract for admin operations.
///
/// SECURITY: frontend role checks only HIDE these screens. Real authorization
/// is enforced by the backend/Firestore rules (custom claims); never trust
/// the client for admin capabilities.
abstract class AdminRepository {
  Future<AdminStats> getStats();

  Future<List<BloodStockModel>> getInventory();
  Future<BloodStockModel> upsertStock(BloodStockModel stock);
  Future<void> deleteStock(String stockId);

  Future<List<BloodRequestModel>> getRequests();
  Future<void> updateRequestStatus(String requestId, BloodRequestStatus status);

  Future<List<DonorModel>> getDonors();
  Future<void> removeDonor(String donorId);

  Future<List<HospitalModel>> getHospitals();

  Future<List<UserModel>> getUsers();

  Future<void> broadcastNotification(String title, String body);
}
