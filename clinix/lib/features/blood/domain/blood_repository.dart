import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';

/// Contract for blood stock & requests.
abstract class BloodRepository {
  /// Search availability. All filters optional; combine as needed.
  Future<List<BloodStockModel>> getBloodStock({
    String? bloodGroup,
    String? location,
    String? hospital,
    bool availableOnly,
    String? query,
  });

  Future<BloodStockModel?> getStockById(String id);

  Future<BloodRequestModel> submitRequest(BloodRequestModel request);

  Future<List<BloodRequestModel>> getMyRequests();
}
