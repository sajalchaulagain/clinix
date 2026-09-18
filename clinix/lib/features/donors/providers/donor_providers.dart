import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/models/donor_model.dart';
import '../data/mock_donor_repository.dart';
import '../domain/donor_repository.dart';

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  // BACKEND INTEGRATION: replace with API implementation (mediated contact).
  return MockDonorRepository();
});

final donorSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final donorBloodGroupFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final donorAvailableOnlyProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final filteredDonorsProvider =
    FutureProvider.autoDispose<List<DonorModel>>((ref) {
  final query = ref.watch(donorSearchQueryProvider);
  final group = ref.watch(donorBloodGroupFilterProvider);
  final availableOnly = ref.watch(donorAvailableOnlyProvider);
  return ref.watch(donorRepositoryProvider).getDonors(
        bloodGroup: group,
        query: query,
        availableOnly: availableOnly,
      );
});

final myDonorProfileProvider = FutureProvider.autoDispose<DonorModel?>((ref) {
  return ref.watch(donorRepositoryProvider).getMyDonorProfile();
});

/// Handles "become a donor" + contact request form submissions.
class DonorActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      ref.invalidate(filteredDonorsProvider);
      ref.invalidate(myDonorProfileProvider);
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

  Future<bool> register({
    required String bloodGroup,
    required String location,
    DateTime? lastDonationDate,
    bool isAvailable = true,
  }) {
    return _run(() => ref.read(donorRepositoryProvider).becomeDonor(
          bloodGroup: bloodGroup,
          location: location,
          lastDonationDate: lastDonationDate,
          isAvailable: isAvailable,
        ));
  }

  Future<bool> requestContact(String donorId, {String? note}) {
    return _run(() =>
        ref.read(donorRepositoryProvider).requestDonorContact(donorId, note: note));
  }
}

final donorActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<DonorActionController, void>(
  DonorActionController.new,
);
