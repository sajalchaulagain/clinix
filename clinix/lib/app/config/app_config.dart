import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration read from the bundled `.env` asset.
///
/// Only PUBLIC configuration belongs here (base URLs, feature flags).
/// Secrets must never ship in a Flutter binary; sensitive operations are
/// performed by the FastAPI backend on behalf of the app.
class AppConfig {
  AppConfig._();

  /// Base URL of the future FastAPI backend. Only used when mock mode is off.
  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'http://localhost:8000';

  /// When true (default during frontend development), repositories serve
  /// clearly-labelled mock data instead of calling the network.
  static bool get useMockData =>
      (dotenv.maybeGet('USE_MOCK_DATA') ?? 'true').toLowerCase() == 'true';

  /// When true, Firebase-backed implementations are wired in. Requires
  /// `firebase_options.dart` generated via `flutterfire configure`.
  static bool get useFirebase =>
      (dotenv.maybeGet('USE_FIREBASE') ?? 'false').toLowerCase() == 'true';

  static Duration get connectTimeout => Duration(
        milliseconds:
            int.tryParse(dotenv.maybeGet('API_CONNECT_TIMEOUT_MS') ?? '') ??
                15000,
      );

  static Duration get receiveTimeout => Duration(
        milliseconds:
            int.tryParse(dotenv.maybeGet('API_RECEIVE_TIMEOUT_MS') ?? '') ??
                90000,
      );
}
