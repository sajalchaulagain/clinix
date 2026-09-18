import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';

enum LegalDocType { about, terms, privacy }

/// One screen for About / Terms / Privacy — content is demo copy to be
/// reviewed legally before production release.
class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key, required this.type});

  final LegalDocType type;

  String get _title => switch (type) {
        LegalDocType.about => 'About CliniX',
        LegalDocType.terms => 'Terms of Use',
        LegalDocType.privacy => 'Privacy Policy',
      };

  String get _body => switch (type) {
        LegalDocType.about => '''
${AppConstants.appName} — ${AppConstants.tagline}

CliniX is the modern evolution of the "Hamro Upachar" project: a smart healthcare, medicine and blood support platform built with Flutter.

What CliniX offers:
• Upachar Sathi — an AI assistant for general health information
• Baidyek Sathi — traditional Ayurvedic wellness information
• Medicine scanner, information and comparison tools
• Well-being screening with supportive guidance
• Blood stock search, requests, donor and hospital directories
• Medicine reminders that work offline

CliniX is a SUPPORT platform. It does not provide medical diagnosis, prescriptions, or emergency care. Always consult qualified healthcare professionals for medical decisions.

Version 1.0.0 (demo build for hackathon presentation).
''',
        LegalDocType.terms => '''
DEMO TERMS — replace with legally reviewed terms before release.

1. CliniX provides health information and coordination support, not medical advice, diagnosis, or treatment.
2. AI-generated content (including Upachar Sathi, Baidyek Sathi, medicine analysis and screening summaries) is informational and may be inaccurate. Verify with qualified professionals.
3. In an emergency, contact local emergency services. Do not rely on this app in urgent situations.
4. Blood availability data is provided by hospitals/blood banks and can change rapidly; always confirm directly.
5. Misuse of the platform (false requests, harassment of donors) may lead to account suspension.
''',
        LegalDocType.privacy => '''
DEMO PRIVACY POLICY — replace with a legally reviewed policy before release.

• Your health information is sensitive. CliniX stores only the details needed to provide its features.
• Reminder data is stored on your device in this demo build.
• When the backend is connected, account and health data will be processed according to this policy with encryption in transit.
• Donor contact details are never exposed publicly; contact requests are mediated by the platform.
• You may request data deletion via the account settings (backend phase).
''',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(
            _body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ),
      ),
    );
  }
}
