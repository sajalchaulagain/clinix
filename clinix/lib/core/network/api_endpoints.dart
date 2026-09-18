/// Endpoint placeholders for the future FastAPI backend.
///
/// ⚠️ BACKEND INTEGRATION
/// These paths are DRAFT placeholders so repositories have a single place to
/// reference. They are NOT the final API contract. During the backend
/// implementation phase, confirm each path against the FastAPI routers and
/// update ONLY this file — repositories and UI should not need changes.
class ApiEndpoints {
  ApiEndpoints._();

  // TODO(backend): confirm auth session/token flow (Firebase ID token verification).
  static const String authMe = '/api/v1/auth/me';

  // TODO(backend): AI assistants (Upachar Sathi / Baidyek Sathi) via OpenRouter.
  static const String aiChat = '/api/v1/ai/chat';
  static const String ayurvedicChat = '/api/v1/ayurvedic/chat';

  // TODO(backend): image upload + analysis (OpenRouter vision, openFDA, RxNorm).
  static const String medicineAnalyze = '/api/v1/medicines/analyze';
  static const String medicineCompare = '/api/v1/medicines/compare';
  static const String medicineInfo = '/api/v1/medicines/info';

  // TODO(backend): mental-health screening analysis.
  static const String mentalHealthAnalyze = '/api/v1/mental-health/analyze';

  // TODO(backend): blood stock, requests, donors, hospitals (may be Firestore-
  // backed; decide in backend phase which data flows through FastAPI vs Firebase).
  static const String bloodStock = '/api/v1/blood/stock';
  static const String bloodRequests = '/api/v1/blood/requests';
  static const String donors = '/api/v1/donors';
  static const String hospitals = '/api/v1/hospitals';

  // TODO(backend): admin operations.
  static const String adminStats = '/api/v1/admin/stats';
  static const String adminInventory = '/api/v1/admin/blood-inventory';
}
