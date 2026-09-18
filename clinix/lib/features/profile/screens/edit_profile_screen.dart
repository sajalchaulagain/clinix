import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../auth/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  DateTime? _dateOfBirth;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dateOfBirth = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            dateOfBirth: _dateOfBirth,
          );
      if (mounted) {
        context.showSnackBar('Profile updated.');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        context.showSnackBar('Could not update your profile.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.fullName,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v, optional: true),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Date of birth', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs + 2),
                OutlinedButton.icon(
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(
                    _dateOfBirth == null
                        ? 'Select date (optional)'
                        : DateFormatters.date(_dateOfBirth!),
                  ),
                  onPressed: _pickDob,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Email cannot be changed in this version.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
