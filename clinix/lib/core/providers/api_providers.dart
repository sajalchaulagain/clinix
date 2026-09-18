import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../network/api_client.dart';
import '../services/firebase/auth_service.dart';

/// Factory that builds an [ApiClient] with a FRESH Firebase ID token.
///
/// Why a factory instead of caching a client: ID tokens expire (~1h), and a
/// stale token means 401s. Resolving the token just before each call keeps
/// authenticated traffic reliable without any background scheduler.
class ApiClientFactory {
  ApiClientFactory();

  final _authService = FirebaseAuthService();

  Future<ApiClient> build() async {
    // Mock mode never calls the backend; Firebase mode attaches real tokens.
    if (!AppConfig.useMockData && AppConfig.useFirebase) {
      final token = await _authService.getIdToken();
      return ApiClient(authToken: token);
    }
    return ApiClient();
  }
}

/// Single entry point used by every `Api*Repository`. Only wired when
/// `USE_MOCK_DATA=false`.
final apiClientProvider = Provider<ApiClientFactory>((ref) {
  return ApiClientFactory();
});
