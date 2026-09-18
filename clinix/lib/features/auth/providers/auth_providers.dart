import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/firebase/auth_service.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../shared/models/user_model.dart';
import '../data/firebase_auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../domain/auth_repository.dart';

/// The single binding point for the auth implementation.
///
/// Swap behavior via `.env`:
///   USE_MOCK_DATA=true  -> MockAuthRepository (default, demo mode)
///   USE_FIREBASE=true   -> FirebaseAuthRepository (needs flutterfire config)
/// No UI code changes needed when switching.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useFirebase && !AppConfig.useMockData) {
    return FirebaseAuthRepository(FirebaseAuthService(), FirestoreService());
  }
  final storage = ref.watch(localStorageServiceProvider);
  return MockAuthRepository(storage);
});

/// Stream of the signed-in user (null when signed out). The router redirect
/// listens to this to guard authenticated/admin routes.
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Convenience accessor for the current user (nullable).
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Handles auth form actions with loading/error state (`AsyncValue<void>`).
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Runs [action] with loading/error state handling. Returns true on success
  /// so screens can navigate; error text is exposed via state for snackbars.
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

  Future<bool> signIn(String email, String password) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
  }) {
    return _run(
      () => _repository.signUp(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        dateOfBirth: dateOfBirth,
        bloodGroup: bloodGroup,
        emergencyContact: emergencyContact,
      ),
    );
  }

  Future<bool> sendPasswordResetEmail(String email) {
    return _run(() => _repository.sendPasswordResetEmail(email));
  }

  Future<bool> resendVerificationEmail() {
    return _run(() => _repository.sendEmailVerification());
  }

  Future<bool> checkEmailVerified() async {
    return _run(() async {
      final verified = await _repository.checkEmailVerified();
      if (!verified) {
        throw const AuthException(
          'Your email is not verified yet. Please check your inbox.',
        );
      }
    });
  }

  Future<void> signOut() => _run(() => _repository.signOut());
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);
