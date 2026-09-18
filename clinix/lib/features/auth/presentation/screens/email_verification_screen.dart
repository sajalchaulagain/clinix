import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final user = ref.watch(currentUserProvider);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    Future<void> checkVerified() async {
      final success = await ref
          .read(authControllerProvider.notifier)
          .checkEmailVerified();
      if (!context.mounted) return;
      if (success) {
        context.go('/home');
      } else {
        final error = ref.read(authControllerProvider).asError?.error;
        context.showSnackBar(
          error is AppException ? error.message : 'Not verified yet.',
          isError: true,
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.mark_email_unread_outlined,
                  size: 80, color: context.colors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Verify your email',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We sent a verification link to\n${user?.email ?? 'your email'}.\n'
                'Open it, then tap the button below.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: "I've Verified My Email",
                isLoading: isLoading,
                onPressed: checkVerified,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => ref
                        .read(authControllerProvider.notifier)
                        .resendVerificationEmail(),
                child: const Text('Resend verification email'),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
