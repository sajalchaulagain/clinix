import 'dart:async';
import 'dart:convert';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../shared/models/user_model.dart';
import '../domain/auth_repository.dart';

/// ⚠️ MOCK IMPLEMENTATION — UI development only.
///
/// Simulates network latency and keeps a session in SharedPreferences so the
/// demo feels real (login persists across restarts). Replace by binding
/// [FirebaseAuthRepository] once Firebase is configured.
///
/// Demo behavior: any valid email + password (>= 6 chars) signs in.
/// An email containing "admin" gets the admin role so the admin dashboard
/// can be tried; everything else is a patient.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._storage) {
    _restoreFuture = _restoreSession();
  }

  final LocalStorageService _storage;

  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  late final Future<void> _restoreFuture;

  Future<void> _restoreSession() async {
    final raw = _storage.getString(PrefsKeys.mockUser);
    if (raw == null) return;
    try {
      _currentUser = UserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupted mock session -> start signed out.
      await _storage.remove(PrefsKeys.mockUser);
    }
  }

  Future<void> _persist(UserModel? user) async {
    _currentUser = user;
    if (user == null) {
      await _storage.remove(PrefsKeys.mockUser);
    } else {
      await _storage.setString(PrefsKeys.mockUser, jsonEncode(user.toJson()));
    }
    _controller.add(user);
  }

  // Simulated latency so loading states are genuinely exercised in the demo.
  Future<void> _latency() => Future<void>.delayed(
        const Duration(milliseconds: 900),
      );

  @override
  Stream<UserModel?> authStateChanges() async* {
    // Emit the restored (or absent) session FIRST so listeners never hang in
    // a loading state, then stream subsequent sign-in/out changes.
    await _restoreFuture;
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  UserModel? get currentUser => _currentUser;

  UserRole _roleFor(String email) =>
      email.toLowerCase().contains('admin') ? UserRole.admin : UserRole.patient;

  String _nameFromEmail(String email) {
    final prefix = email.split('@').first;
    final cleaned = prefix.replaceAll(RegExp(r'[^a-zA-Z\s]'), ' ').trim();
    if (cleaned.isEmpty) return 'CliniX User';
    return cleaned
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await _latency();
    if (password.length < 6) {
      throw const AuthException('Incorrect email or password.');
    }
    final existing = _currentUser;
    final user = (existing != null && existing.email == email)
        ? existing
        : UserModel(
            id: 'mock-${email.hashCode}',
            fullName: _nameFromEmail(email),
            email: email,
            role: _roleFor(email),
            bloodGroup: 'O+',
            createdAt: DateTime.now(),
            emailVerified: true,
          );
    await _persist(user);
    return user;
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
  }) async {
    await _latency();
    final user = UserModel(
      id: 'mock-${email.hashCode}',
      fullName: fullName,
      email: email,
      phone: phone,
      role: _roleFor(email),
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
      emergencyContact: emergencyContact,
      createdAt: DateTime.now(),
      emailVerified: false,
    );
    await _persist(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) => _latency();

  @override
  Future<void> sendEmailVerification() => _latency();

  @override
  Future<bool> checkEmailVerified() async {
    await _latency();
    final user = _currentUser;
    if (user == null) return false;
    await _persist(user.copyWith(emailVerified: true));
    return true;
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
    String? photoUrl,
  }) async {
    await _latency();
    final user = _currentUser;
    if (user == null) {
      throw const AuthException('You need to be signed in to update your profile.');
    }
    final updated = user.copyWith(
      fullName: fullName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
      emergencyContact: emergencyContact,
      photoUrl: photoUrl,
    );
    await _persist(updated);
    return updated;
  }

  @override
  Future<void> signOut() async {
    await _latency();
    await _persist(null);
  }
}
