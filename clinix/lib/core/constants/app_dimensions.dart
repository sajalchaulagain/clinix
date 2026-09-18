/// Shared spacing, radius and sizing tokens.
///
/// Using named tokens avoids "magic numbers" scattered through widget code
/// and keeps the UI visually consistent.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Default horizontal screen padding.
  static const double screenPadding = 20;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class AppSizes {
  AppSizes._();

  static const double minTouchTarget = 48;
  static const double bottomNavHeight = 68;
  static const double iconBox = 48;
}
