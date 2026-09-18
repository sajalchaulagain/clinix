import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
    } else {
      context.showSnackBar(
        'Could not send the reset email. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: _emailSent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Icon(Icons.mark_email_read_outlined,
                        size: 72, color: context.colors.secondary),
                    const SizedBox(height: AppSpacing.md),
                    Text('Check your inbox',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'If an account exists for ${_emailController.text.trim()}, '
                      'a password reset link is on its way.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Back to Sign In',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Text('Forgot your password?',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Enter the email linked to your account and we will '
                        'send you a reset link.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        hint: 'you@example.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Send Reset Link',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
