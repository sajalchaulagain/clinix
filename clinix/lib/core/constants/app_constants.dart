/// Application-wide constants: branding, domain vocabularies, pref keys.
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'CliniX';
  static const String tagline = 'Your Smart Healthcare Companion';
  static const String aiAssistantName = 'Upachar Sathi';
  static const String ayurvedicAssistantName = 'Baidyek Sathi';

  /// Nepal ambulance number. Region-dependent; expose in settings later.
  static const String emergencyNumber = '102';

  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  static const List<String> reminderFrequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Weekly',
  ];
}

/// SharedPreferences keys, centralised so features don't drift apart.
class PrefsKeys {
  PrefsKeys._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String mockUser = 'mock_auth_user';
  static const String reminders = 'medicine_reminders';
  static const String becomeDonorProfile = 'donor_profile_flag';
}
