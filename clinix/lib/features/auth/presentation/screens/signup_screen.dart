import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';
import '../widgets/auth_header.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Optional medical fields — only collected if the user chooses to add them.
  bool _showOptionalFields = false;
  String? _bloodGroup;
  final _emergencyContactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success =
        await ref.read(authControllerProvider.notifier).signUp(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              bloodGroup: _showOptionalFields ? _bloodGroup : null,
              emergencyContact: _showOptionalFields
                  ? _emergencyContactController.text.trim()
                  : null,
            );
    if (!mounted) return;
    if (success) {
      context.go('/verify-email');
    } else {
      final error = ref.read(authControllerProvider).asError?.error;
      context.showSnackBar(
        error is AppException ? error.message : 'Sign-up failed. Try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(subtitle: 'Join CliniX'),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'Your full name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.fullName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
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
                  label: 'Phone Number',
                  controller: _phoneController,
                  hint: '+977 98XXXXXXXX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmController,
                  hint: 'Repeat your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.md),

                // Optional health info — collapsible so signup stays quick.
                Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Optional health information',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: const Text(
                        'Blood group & emergency contact (helps in blood support)'),
                    onExpansionChanged: (expanded) =>
                        setState(() => _showOptionalFields = expanded),
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        initialValue: _bloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group (optional)',
                          prefixIcon: Icon(Icons.bloodtype_outlined),
                        ),
                        items: AppConstants.bloodGroups
                            .map((group) => DropdownMenuItem(
                                value: group, child: Text(group)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _bloodGroup = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Emergency Contact (optional)',
                        controller: _emergencyContactController,
                        hint: '+977 98XXXXXXXX',
                        prefixIcon: Icons.contact_emergency_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => Validators.phone(v, optional: true),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'By creating an account you agree to handle your health data '
                  'responsibly. CliniX is a support platform, not a medical provider.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
