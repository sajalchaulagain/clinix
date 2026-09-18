import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around SharedPreferences for simple key/value persistence.
///
/// Used for: onboarding completion flag, theme/language settings, the local
/// (offline-capable) reminder store, and the mock session while the backend
/// is not connected. Not for sensitive data — tokens belong to Firebase Auth.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static LocalStorageService? _instance;

  /// Must be awaited once in `main()` before app start.
  static Future<LocalStorageService> init() async {
    _instance ??= LocalStorageService(await SharedPreferences.getInstance());
    return _instance!;
  }

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  // ---- JSON convenience helpers (used by the local reminder repository) ----

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> items) =>
      setString(key, jsonEncode(items));

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}

/// Overridden in `main()` with the instance initialised before `runApp`.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageServiceProvider must be overridden in ProviderScope.overrides',
  );
});
