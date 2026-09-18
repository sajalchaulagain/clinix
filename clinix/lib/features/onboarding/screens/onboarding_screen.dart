import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/onboarding_providers.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingPageData(
    icon: Icons.local_hospital_outlined,
    title: 'Healthcare in One Place',
    description:
        'Doctors, hospitals, medicine information and blood support — all in a single, calm companion app.',
  ),
  _OnboardingPageData(
    icon: Icons.medication_outlined,
    title: 'Understand Your Medicines',
    description:
        'Scan medicine packages to get clear, plain-language information about uses, precautions and interactions.',
  ),
  _OnboardingPageData(
    icon: Icons.bloodtype_outlined,
    title: 'Find and Manage Blood Support',
    description:
        'Search blood availability near you, connect with donors and request blood when it matters most.',
  ),
  _OnboardingPageData(
    icon: Icons.smart_toy_outlined,
    title: 'Your AI Healthcare Companion',
    description:
        'Upachar Sathi answers general health questions — always with safe, informational guidance.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: index == _currentPage ? 26 : 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? colors.primary
                              : colors.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    child: AppButton(
                      label: _isLastPage ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (_isLastPage) {
                          _finish();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 132,
            width: 132,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(data.icon, size: 64, color: colors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            data.title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
