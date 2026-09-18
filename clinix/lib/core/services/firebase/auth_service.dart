import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper over FirebaseAuth.
///
/// This service is only used when `USE_FIREBASE=true` in `.env` and Firebase
/// has been configured via `flutterfire configure`. Repositories call this
/// service; widgets never touch FirebaseAuth directly.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? instance})
      : _auth = instance ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() =>
      _auth.currentUser?.sendEmailVerification() ?? Future.value();

  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Fresh ID token to send to the FastAPI backend as `Authorization: Bearer`.
  Future<String?> getIdToken() => _auth.currentUser?.getIdToken() ?? Future.value(null);

  Future<void> signOut() => _auth.signOut();
}
