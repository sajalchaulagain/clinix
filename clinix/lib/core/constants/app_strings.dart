/// Central text constants, focused on branding + medically sensitive copy.
///
/// LOCALIZATION: feature screens currently use literal strings (English).
/// Before adding Nepali, migrate strings to ARB files / `AppLocalizations`.
/// Medically sensitive wording is centralised HERE so it can be reviewed in
/// one place and translated with extra care.
class AppStrings {
  AppStrings._();

  // ---- Medical safety copy (review before changing!) ----
  static const String aiDisclaimer =
      'Upachar Sathi provides AI-generated health information for general '
      'understanding only. It is not medical advice, not a diagnosis, and not '
      'a replacement for a qualified doctor.';

  static const String ayurvedicDisclaimer =
      'Baidyek Sathi shares traditional Ayurvedic wellness information. These '
      'suggestions are not medically validated treatments or guaranteed cures. '
      'Consult a qualified practitioner before starting any remedy.';

  static const String aiInfoLabel = 'AI-generated information';

  static const String screeningDisclaimer =
      'This is a well-being screening summary, not a medical diagnosis. '
      'Only a qualified mental-health professional can evaluate your health.';

  static const String medicineInfoDisclaimer =
      'Medicine information shown here is AI-generated general information. '
      'Always verify with a pharmacist or doctor before taking any medicine.';

  static const String emergencyBannerText =
      'If this is an emergency, contact local emergency services immediately.';

  // ---- Generic state copy ----
  static const String genericErrorTitle = 'Something went wrong';
  static const String genericErrorBody =
      'We could not complete that action. Please check your connection and try again.';
  static const String emptyGeneric = 'Nothing here yet';
  static const String retry = 'Retry';

  // ---- Navigation labels ----
  static const String navHome = 'Home';
  static const String navExplore = 'Explore';
  static const String navBlood = 'Blood';
  static const String navReminders = 'Reminders';
  static const String navProfile = 'Profile';
}
