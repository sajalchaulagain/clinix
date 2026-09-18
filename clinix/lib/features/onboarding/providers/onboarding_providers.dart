import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';

/// Persists and exposes the "has the user seen onboarding" flag so onboarding
/// shows only once (first launch).
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getBool(PrefsKeys.onboardingComplete);
  }

  Future<void> complete() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setBool(PrefsKeys.onboardingComplete, true);
    state = true;
  }
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
