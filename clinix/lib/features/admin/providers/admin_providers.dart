import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../data/mock_admin_repository.dart';
import '../domain/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  // BACKEND INTEGRATION: replace with ApiAdminRepository. Server MUST
  // re-verify admin role (custom claim) on every call.
  return MockAdminRepository();
});

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) {
  return ref.watch(adminRepositoryProvider).getStats();
});

final adminInventoryProvider =
    AsyncNotifierProvider<AdminInventoryNotifier, List<BloodStockModel>>(
  AdminInventoryNotifier.new,
);

class AdminInventoryNotifier extends AsyncNotifier<List<BloodStockModel>> {
  @override
  Future<List<BloodStockModel>> build() {
    return ref.read(adminRepositoryProvider).getInventory();
  }

  Future<void> _reload() async =>
      state = AsyncData(await ref.read(adminRepositoryProvider).getInventory());

  Future<bool> upsert(BloodStockModel stock) async {
    try {
      await ref.read(adminRepositoryProvider).upsertStock(stock);
      await _reload();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String stockId) async {
    try {
      await ref.read(adminRepositoryProvider).deleteStock(stockId);
      await _reload();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final adminRequestsProvider =
    FutureProvider.autoDispose<List<BloodRequestModel>>((ref) {
  return ref.watch(adminRepositoryProvider).getRequests();
});

final adminDonorsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(adminRepositoryProvider).getDonors();
});

final adminHospitalsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(adminRepositoryProvider).getHospitals();
});

final adminUsersProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(adminRepositoryProvider).getUsers();
});

/// Admin actions with loading/error handling (status changes, broadcasts).
class AdminActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (error) {
      state = AsyncError(
        error is AppException ? error : UnknownAppException(cause: error),
        StackTrace.current,
      );
      return false;
    }
  }

  Future<bool> updateRequestStatus(
    String requestId,
    BloodRequestStatus status,
  ) {
    return _run(() async {
      await ref
          .read(adminRepositoryProvider)
          .updateRequestStatus(requestId, status);
      ref.invalidate(adminRequestsProvider);
      ref.invalidate(adminStatsProvider);
    });
  }

  Future<bool> broadcast(String title, String body) {
    return _run(() =>
        ref.read(adminRepositoryProvider).broadcastNotification(title, body));
  }
}

final adminActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminActionController, void>(
  AdminActionController.new,
);
