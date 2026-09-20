/// Canonical REST contract with the CliniX FastAPI backend (backend/app/api).
///
/// ⚠️ This file IS the contract: if an endpoint changes on the backend,
/// update it HERE and in the corresponding repository together. The UI never
/// builds paths by hand.
class ApiEndpoints {
  ApiEndpoints._();

  // Health (unauthenticated)
  static const String health = '/api/v1/health';

  // Auth / profile (identity + role always come from the verified token
  // server-side — these endpoints never accept uid or role in the body)
  static const String authMe = '/api/v1/auth/me';
  static const String authUpdateProfile = '/api/v1/auth/users/me';

  // AI assistants (Upachar Sathi / Baidyek Sathi)
  static const String aiChat = '/api/v1/ai/chat';
  static const String ayurvedicChat = '/api/v1/ayurvedic/chat';

  // Medicines (vision scan, compare, guided info, guide search)
  static const String medicineAnalyze = '/api/v1/medicines/analyze';
  static const String medicineCompare = '/api/v1/medicines/compare';
  static const String medicineInfo = '/api/v1/medicines/info';
  static const String medicineSearch = '/api/v1/medicines/search';

  // Mental-health screening (NON-DIAGNOSTIC)
  static const String mentalHealthAnalyze = '/api/v1/mental-health/analyze';

  // Blood stock & requests
  static const String bloodStock = '/api/v1/blood/stock';
  static String bloodStockById(String id) => '/api/v1/blood/stock/$id';
  static const String bloodRequests = '/api/v1/blood/requests';
  static const String bloodRequestsMy = '/api/v1/blood/requests/my';
  static String bloodRequestById(String id) => '/api/v1/blood/requests/$id';
  static String bloodRequestStatus(String id) =>
      '/api/v1/blood/requests/$id/status';

  // Blood donation requests
  static const String bloodDonationRequests = '/api/v1/blood/donation-requests';
  static const String bloodDonationRequestsMy =
      '/api/v1/blood/donation-requests/my';
  static String bloodDonationRequestById(String id) =>
      '/api/v1/blood/donation-requests/$id';
  static String bloodDonationRequestCancel(String id) =>
      '/api/v1/blood/donation-requests/$id/cancel';


  // Donors (contact details are never returned by the backend)
  static const String donors = '/api/v1/donors';
  static const String donorMe = '/api/v1/donors/me';
  static String donorContact(String id) =>
      '/api/v1/donors/$id/contact-request';

  // Hospitals & doctors
  static const String hospitals = '/api/v1/hospitals';
  static String hospitalById(String id) => '/api/v1/hospitals/$id';
  static const String doctors = '/api/v1/doctors';
  static const String doctorsRecommended = '/api/v1/doctors/recommended';
  static String doctorById(String id) => '/api/v1/doctors/$id';

  // Notification center
  static const String notifications = '/api/v1/notifications';
  static String notificationRead(String id) =>
      '/api/v1/notifications/$id/read';
  static const String notificationsReadAll = '/api/v1/notifications/read-all';
  static const String deviceToken = '/api/v1/notifications/device-token';

  // Admin (real authorization enforced server-side via custom claims)
  static const String adminStats = '/api/v1/admin/stats';
  static const String adminInventory = '/api/v1/admin/blood-inventory';
  static String adminInventoryById(String id) =>
      '/api/v1/admin/blood-inventory/$id';
  static const String adminBloodRequests = '/api/v1/admin/blood-requests';
  static String adminBloodRequestStatus(String id) =>
      '/api/v1/admin/blood-requests/$id/status';
  static const String adminDonors = '/api/v1/admin/donors';
  static String adminDonorById(String id) => '/api/v1/admin/donors/$id';
  static const String adminHospitals = '/api/v1/admin/hospitals';
  static const String adminUsers = '/api/v1/admin/users';
  static const String adminBroadcast =
      '/api/v1/admin/notifications/broadcast';
}
