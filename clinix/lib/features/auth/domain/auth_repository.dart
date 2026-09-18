import '../../../shared/models/user_model.dart';

/// Contract for authentication. The UI depends ONLY on this interface.
///
/// Implementations:
///   * [MockAuthRepository] — active while `USE_MOCK_DATA=true` (default).
///   * [FirebaseAuthRepository] — wraps Firebase Auth + Firestore profile.
///
/// BACKEND INTEGRATION: the FastAPI backend verifies Firebase ID tokens
/// server-side; this repository remains the single auth entry point in the UI.
abstract class AuthRepository {
  Stream<UserModel?> authStateChanges();

  UserModel? get currentUser;

  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<bool> checkEmailVerified();

  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
    String? photoUrl,
  });

  Future<void> signOut();
}
