import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(_emailController.text.trim(), _passwordController.text);
    // Successful sign-in flips authStateProvider -> the router redirects to
    // /home automatically, so no manual navigation here.
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).asError?.error;
      context.showSnackBar(
        error is AppException ? error.message : 'Sign-in failed. Try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const AuthHeader(subtitle: 'Welcome back. Sign in to continue.'),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: Validators.password,
                      textInputAction: TextInputAction.done,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Sign In',
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                      style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Demo mode: any email + 6-char password signs in.\n'
                'Use an email containing "admin" to try the admin role.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
