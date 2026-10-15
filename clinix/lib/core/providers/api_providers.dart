import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../network/api_client.dart';
import '../services/firebase/auth_service.dart';

/// Factory that builds an [ApiClient] with a FRESH Firebase ID token.
///
/// Why a factory instead of caching a client: ID tokens expire (~1h), and a
/// stale token means 401s. Resolving the token just before each call keeps
/// authenticated traffic reliable without any background scheduler.
///
/// Token attachment rules:
///   1. USE_FIREBASE=true  — always fetch and attach the real Firebase ID token
///      when any live network call is made (useLiveAi=true OR useMockData=false).
///   2. USE_FIREBASE=false + USE_LIVE_AI=true — attach `Bearer dev-user`.
///      ⚠️  This only works when the backend has MOCK_EXTERNAL_SERVICES=true.
///      Do NOT ship production builds with this combination.
///   3. Everything else (pure mock) — no Authorization header.
class ApiClientFactory {
  ApiClientFactory();

  final _authService = FirebaseAuthService();

  /// Whether live network calls need an Authorization header.
  bool get _needsAuth =>
      AppConfig.useLiveAi || !AppConfig.useMockData;

  Future<ApiClient> build() async {
    if (!_needsAuth) {
      // Pure mock mode — no backend traffic, no token needed.
      return ApiClient();
    }

    if (AppConfig.useFirebase) {
      // Real Firebase session: fetch a fresh ID token (auto-refreshes if expired).
      final token = await _authService.getIdToken();
      if (token == null || token.isEmpty) {
        debugPrint(
          '[ApiClientFactory] WARNING: Firebase user is signed out or token '
          'unavailable. Request will be sent without Authorization header '
          '→ expect 401 from the backend.',
        );
      }
      return ApiClient(authToken: token);
    }

    // USE_FIREBASE=false + USE_LIVE_AI=true:
    // Fall back to the static dev token accepted by the backend when
    // MOCK_EXTERNAL_SERVICES=true. Remove this path before going to production.
    debugPrint(
      '[ApiClientFactory] DEV MODE: sending Authorization: Bearer dev-user. '
      'Backend must have MOCK_EXTERNAL_SERVICES=true.',
    );
    return ApiClient(authToken: 'dev-user');
  }
}

/// Single entry point used by every `Api*Repository`.
final apiClientProvider = Provider<ApiClientFactory>((ref) {
  return ApiClientFactory();
});
