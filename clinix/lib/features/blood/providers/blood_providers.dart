import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/blood_request_model.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../data/api_blood_repository.dart';
import '../data/mock_blood_repository.dart';
import '../domain/blood_repository.dart';

/// Returns the real FastAPI-backed repository when USE_MOCK_DATA=false.
final bloodRepositoryProvider = Provider<BloodRepository>((ref) {
  if (!AppConfig.useMockData) {
    return ApiBloodRepository(ref.read(apiClientProvider));
  }
  return MockBloodRepository();
});

/// Combined filter state for the blood stock screen.
class BloodFilter extends Equatable {
  const BloodFilter({
    this.bloodGroup,
    this.location,
    this.hospital,
    this.availableOnly = false,
    this.query = '',
  });

  final String? bloodGroup;
  final String? location;
  final String? hospital;
  final bool availableOnly;
  final String query;

  bool get hasActiveFilters =>
      bloodGroup != null || location != null || hospital != null || availableOnly;

  BloodFilter copyWith({
    String? bloodGroup,
    bool clearBloodGroup = false,
    String? location,
    bool clearLocation = false,
    String? hospital,
    bool clearHospital = false,
    bool? availableOnly,
    String? query,
  }) {
    return BloodFilter(
      bloodGroup: clearBloodGroup ? null : (bloodGroup ?? this.bloodGroup),
      location: clearLocation ? null : (location ?? this.location),
      hospital: clearHospital ? null : (hospital ?? this.hospital),
      availableOnly: availableOnly ?? this.availableOnly,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props =>
      [bloodGroup, location, hospital, availableOnly, query];
}

class BloodFilterNotifier extends AutoDisposeNotifier<BloodFilter> {
  @override
  BloodFilter build() => const BloodFilter();

  void update(BloodFilter filter) => state = filter;

  void setQuery(String query) => state = state.copyWith(query: query);

  void setBloodGroup(String? group) => state = group == null
      ? state.copyWith(clearBloodGroup: true)
      : state.copyWith(bloodGroup: group);

  void toggleAvailableOnly(bool value) =>
      state = state.copyWith(availableOnly: value);

  void clear() => state = const BloodFilter();
}

final bloodFilterProvider =
    AutoDisposeNotifierProvider<BloodFilterNotifier, BloodFilter>(
  BloodFilterNotifier.new,
);

final filteredBloodStockProvider =
    FutureProvider.autoDispose<List<BloodStockModel>>((ref) {
  final filter = ref.watch(bloodFilterProvider);
  return ref.watch(bloodRepositoryProvider).getBloodStock(
        bloodGroup: filter.bloodGroup,
        location: filter.location,
        hospital: filter.hospital,
        availableOnly: filter.availableOnly,
        query: filter.query,
      );
});

/// The user's own blood requests (pending/approved history).
final myBloodRequestsProvider =
    FutureProvider.autoDispose<List<BloodRequestModel>>((ref) {
  return ref.watch(bloodRepositoryProvider).getMyRequests();
});

/// Form submission handler with AsyncValue state for the request screen.
class BloodRequestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit(BloodRequestModel request) async {
    state = const AsyncLoading();
    try {
      await ref.read(bloodRepositoryProvider).submitRequest(request);
      ref.invalidate(myBloodRequestsProvider);
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
}

final bloodRequestControllerProvider = AutoDisposeAsyncNotifierProvider<
    BloodRequestController, void>(BloodRequestController.new);
