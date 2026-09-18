import '../constants/app_constants.dart';

/// Reusable form validators.
///
/// Frontend validation improves UX (instant, friendly feedback) but is NOT a
/// security boundary — the backend re-validates everything. Keep messages
/// short and actionable.
class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? fullName(String? value) {
    final base = required(value, fieldName: 'Full name');
    if (base != null) return base;
    if (value!.trim().length < 3) return 'Please enter your full name';
    return null;
  }

  static String? email(String? value) {
    final base = required(value, fieldName: 'Email');
    if (base != null) return base;
    final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!pattern.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value, {bool optional = false}) {
    if (value == null || value.trim().isEmpty) {
      return optional ? null : 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    final base = required(value, fieldName: 'Password');
    if (base != null) return base;
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final base = required(value, fieldName: 'Confirm password');
    if (base != null) return base;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? bloodGroup(String? value) {
    if (value == null || value.isEmpty) return 'Select a blood group';
    if (!AppConstants.bloodGroups.contains(value)) return 'Invalid blood group';
    return null;
  }

  static String? medicineName(String? value) {
    final base = required(value, fieldName: 'Medicine name');
    if (base != null) return base;
    if (value!.trim().length < 2) return 'Enter a valid medicine name';
    return null;
  }

  static String? dosage(String? value) =>
      required(value, fieldName: 'Dosage (e.g. 500mg)');

  static String? units(String? value) {
    final base = required(value, fieldName: 'Units');
    if (base != null) return base;
    final parsed = int.tryParse(value!);
    if (parsed == null || parsed <= 0 || parsed > 20) {
      return 'Enter a valid number of units (1–20)';
    }
    return null;
  }

  static String? location(String? value) =>
      required(value, fieldName: 'Location');

  static String? hospitalName(String? value) =>
      required(value, fieldName: 'Hospital name');
}
