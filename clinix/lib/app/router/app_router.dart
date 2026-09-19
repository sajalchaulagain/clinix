import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_blood_inventory_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_donors_screen.dart';
import '../../features/admin/screens/admin_hospitals_screen.dart';
import '../../features/admin/screens/admin_notifications_screen.dart';
import '../../features/admin/screens/admin_requests_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/ai_assistant/domain/ai_repository.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/ayurvedic/screens/ayurvedic_screen.dart';
import '../../features/blood/screens/blood_detail_screen.dart';
import '../../features/blood/screens/blood_request_screen.dart';
import '../../features/blood/screens/blood_stock_screen.dart';
import '../../features/doctors/screens/doctor_detail_screen.dart';
import '../../features/doctors/screens/doctors_screen.dart';
import '../../features/donors/screens/become_donor_screen.dart';
import '../../features/donors/screens/donors_screen.dart';
import '../../features/home/presentation/explore_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/hospitals/screens/hospitals_screen.dart';
import '../../features/medicine/screens/medicine_comparison_screen.dart';
import '../../features/medicine/screens/medicine_info_screen.dart';
import '../../features/medicine/screens/medicine_scan_result_screen.dart';
import '../../features/medicine/screens/medicine_scanner_screen.dart';
import '../../features/mental_health/screens/screening_intro_screen.dart';
import '../../features/mental_health/screens/screening_questions_screen.dart';
import '../../features/mental_health/screens/screening_result_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/providers/onboarding_providers.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/medical_preferences_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/reminders/screens/reminder_form_screen.dart';
import '../../features/reminders/screens/reminders_screen.dart';
import '../../features/settings/screens/legal_info_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/models/blood_stock_model.dart';
import '../../shared/models/doctor_model.dart';
import '../../shared/models/medicine_analysis_model.dart';
import '../../shared/models/reminder_model.dart';
import 'main_shell.dart';

class RoutePaths {
  RoutePaths._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';

  static const home = '/home';
  static const explore = '/explore';
  static const blood = '/blood';
  static const reminders = '/reminders';
  static const profile = '/profile';

  static const admin = '/admin';
}

/// Bridges Riverpod -> GoRouter's `refreshListenable` so redirects re-run
/// whenever auth/onboarding state changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    _authSub = ref.listen(authStateProvider, (_, __) => notifyListeners());
    _onboardingSub =
        ref.listen(onboardingCompleteProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription _authSub;
  late final ProviderSubscription _onboardingSub;

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      // ---- Bootstrap + auth ----
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        builder: (context, state) => const EmailVerificationScreen(),
      ),

      // ---- Bottom-navigation shell ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.blood,
              builder: (context, state) => const BloodStockScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.reminders,
              builder: (context, state) => const RemindersScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // ---- Feature routes (pushed over the shell) ----
      GoRoute(
        path: '/doctors',
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: '/doctors/:id',
        builder: (context, state) =>
            DoctorDetailScreen(doctor: state.extra! as DoctorModel),
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) =>
            const AiChatScreen(persona: AiPersona.upachar),
      ),
      GoRoute(
        path: '/ayurvedic',
        builder: (context, state) => const AyurvedicScreen(),
      ),
      GoRoute(
        path: '/ayurvedic-chat',
        builder: (context, state) =>
            const AiChatScreen(persona: AiPersona.baidyek),
      ),
      GoRoute(
        path: '/mental-health',
        builder: (context, state) => const ScreeningIntroScreen(),
      ),
      GoRoute(
        path: '/mental-health/questions',
        builder: (context, state) => const ScreeningQuestionsScreen(),
      ),
      GoRoute(
        path: '/mental-health/result',
        builder: (context, state) => const ScreeningResultScreen(),
      ),
      GoRoute(
        path: '/medicine-scanner',
        builder: (context, state) => const MedicineScannerScreen(),
      ),
      GoRoute(
        path: '/medicine-result',
        builder: (context, state) => const MedicineScanResultScreen(),
      ),
      GoRoute(
        path: '/medicine-comparison',
        builder: (context, state) => MedicineComparisonScreen(
          analyses: state.extra! as List<MedicineAnalysisModel>,
        ),
      ),
      GoRoute(
        path: '/medicine-info',
        builder: (context, state) => const MedicineInfoScreen(),
      ),
      GoRoute(
        path: '/blood-request',
        builder: (context, state) =>
            BloodRequestScreen(initialBloodGroup: state.extra as String?),
      ),
      GoRoute(
        path: '/blood/:id',
        builder: (context, state) =>
            BloodDetailScreen(stock: state.extra! as BloodStockModel),
      ),
      GoRoute(
        path: '/donors',
        builder: (context, state) => const DonorsScreen(),
      ),
      GoRoute(
        path: '/donors/become',
        builder: (context, state) => const BecomeDonorScreen(),
      ),
      GoRoute(
        path: '/hospitals',
        builder: (context, state) => const HospitalsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/medical-preferences',
        builder: (context, state) => const MedicalPreferencesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (context, state) {
          final doc = switch (state.pathParameters['doc']) {
            'terms' => LegalDocType.terms,
            'privacy' => LegalDocType.privacy,
            _ => LegalDocType.about,
          };
          return LegalInfoScreen(type: doc);
        },
      ),
      GoRoute(
        path: '/reminders/add',
        builder: (context, state) => const ReminderFormScreen(),
      ),
      GoRoute(
        path: '/reminders/edit',
        builder: (context, state) =>
            ReminderFormScreen(existing: state.extra as ReminderModel?),
      ),

      // ---- Admin (role-guarded in _redirect; hidden entry in settings) ----
      GoRoute(
        path: RoutePaths.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/inventory',
        builder: (context, state) => const AdminBloodInventoryScreen(),
      ),
      GoRoute(
        path: '/admin/requests',
        builder: (context, state) => const AdminRequestsScreen(),
      ),
      GoRoute(
        path: '/admin/donors',
        builder: (context, state) => const AdminDonorsScreen(),
      ),
      GoRoute(
        path: '/admin/hospitals',
        builder: (context, state) => const AdminHospitalsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
    ],
  );
});

/// Central redirect logic: onboarding gate -> auth gate -> role gates.
String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  final auth = ref.read(authStateProvider);
  final onboardingDone = ref.read(onboardingCompleteProvider);

  const authRoutes = {
    RoutePaths.login,
    RoutePaths.signup,
    RoutePaths.forgotPassword,
  };

  final isOnboarding = location == RoutePaths.onboarding;
  final isSplash = location == RoutePaths.splash;
  final isAuthRoute = authRoutes.contains(location);
  final isVerifyEmail = location == RoutePaths.verifyEmail;

  // ── Step 1: Auth stream still resolving ────────────────────────────────────
  // Park on splash while waiting. Allow /onboarding to stay if onboarding is
  // not done yet so we never bounce back-and-forth.
  if (auth.isLoading) {
    if (isSplash) return null;
    // If onboarding hasn't been seen yet, let the user stay on /onboarding
    // while we wait (avoids the /splash ↔ /onboarding loop).
    if (!onboardingDone && isOnboarding) return null;
    return RoutePaths.splash;
  }

  final user = auth.valueOrNull;
  final isLoggedIn = user != null;

  // ── Step 2: Onboarding gate ────────────────────────────────────────────────
  // Must be shown once before anything else (auth included).
  if (!onboardingDone && !isOnboarding) return RoutePaths.onboarding;

  // ── Step 3: Auth gate ──────────────────────────────────────────────────────
  // Not signed in: only auth routes and splash are reachable.
  if (!isLoggedIn) {
    if (isAuthRoute || isSplash || isOnboarding) return null;
    return RoutePaths.login;
  }

  // ── Step 4: Signed-in user cleanup ────────────────────────────────────────
  // Keep authenticated users out of onboarding / auth screens / splash.
  if (isOnboarding || isAuthRoute || isSplash) {
    return RoutePaths.home;
  }

  // ── Step 5: Role gates ─────────────────────────────────────────────────────
  // Admin area is role-gated at the routing layer (defense in depth;
  // real authorization is enforced by the backend regardless).
  if (location.startsWith(RoutePaths.admin) && !user.isAdmin) {
    return RoutePaths.home;
  }

  // Everything else is reachable when signed in (incl. verification screen).
  if (isVerifyEmail) return null;
  return null;
}
