import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/firebase/auth_service.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../../shared/models/user_model.dart';
import '../domain/auth_repository.dart';

/// Firebase-backed [AuthRepository].
///
/// Bound by the provider layer when `USE_FIREBASE=true` (see auth_providers).
/// Auth identity comes from Firebase Auth; profile fields (blood group,
/// emergency contact, role) live in the `users` Firestore collection.
///
/// SECURITY: role assignment happens server-side (Firebase custom claims set
/// by the backend) in production — the client merely READS it.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuthService _auth;
  final FirestoreService _firestore;

  static const String _usersCollection = 'users';

  Future<UserModel?> _userFromFirebase(User? firebaseUser) async {
    if (firebaseUser == null) return null;
    try {
      final doc = await _firestore.getDoc(_usersCollection, firebaseUser.uid);
      if (doc.exists) {
        return UserModel.fromJson({'id': firebaseUser.uid, ...doc.data()!});
      }
    } catch (_) {
      // Profile fetch failure should not block auth; fall back to basics.
    }
    return UserModel(
      id: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? 'CliniX User',
      email: firebaseUser.email ?? '',
      role: UserRole.patient,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
    );
  }

  @override
  Stream<UserModel?> authStateChanges() =>
      _auth.authStateChanges().asyncMap(_userFromFirebase);

  @override
  UserModel? get currentUser =>
      throw UnimplementedError('Use authStateChanges stream with Firebase.');

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _auth.signInWithEmail(email: email, password: password);
      final user = await _userFromFirebase(credential.user);
      if (user == null) throw const AuthException('Sign-in failed.');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'FIREBASE AUTH CODE: ${e.code} MESSAGE: ${e.message} PLUGIN: ${e.plugin}');
      throw AuthException(_mapFirebaseError(e), cause: e);
    }
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
    try {
      final credential = await _auth.signUpWithEmail(
        email: email,
        password: password,
        displayName: fullName,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        id: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: UserRole.patient,
        dateOfBirth: dateOfBirth,
        bloodGroup: bloodGroup,
        emergencyContact: emergencyContact,
        createdAt: DateTime.now(),
      );
      await _firestore.setDoc(_usersCollection, uid, user.toJson());
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'FIREBASE AUTH CODE: ${e.code} MESSAGE: ${e.message} PLUGIN: ${e.plugin}');
      throw AuthException(_mapFirebaseError(e), cause: e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email);

  @override
  Future<void> sendEmailVerification() => _auth.sendEmailVerification();

  @override
  Future<bool> checkEmailVerified() => _auth.reloadAndCheckVerified();

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
    String? photoUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('You need to be signed in.');
    final updates = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
    await _firestore.setDoc(_usersCollection, uid, updates);
    final user = await _userFromFirebase(_auth.currentUser);
    if (user == null) throw const AuthException('Profile update failed.');
    return user;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' => 'This user account has been disabled.',
      'operation-not-allowed' =>
        'Email/password login is not enabled in Firebase Console.',
      'configuration-not-found' ||
      'api-key-not-valid' ||
      'project-not-found' =>
        'Firebase project configuration error. Please check options.',
      'network-request-failed' =>
        'No internet connection. Please check your network and retry.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      _ => 'Authentication failed (${e.code}). Please try again.',
    };
  }
}
