import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../auth/providers/auth_providers.dart';

/// Blood group + emergency contact — the health details CliniX uses for
/// blood support matching.
class MedicalPreferencesScreen extends ConsumerStatefulWidget {
  const MedicalPreferencesScreen({super.key});

  @override
  ConsumerState<MedicalPreferencesScreen> createState() =>
      _MedicalPreferencesScreenState();
}

class _MedicalPreferencesScreenState
    extends ConsumerState<MedicalPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emergencyController;
  String? _bloodGroup;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _bloodGroup = user?.bloodGroup;
    _emergencyController =
        TextEditingController(text: user?.emergencyContact ?? '');
  }

  @override
  void dispose() {
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            bloodGroup: _bloodGroup,
            emergencyContact: _emergencyController.text.trim().isEmpty
                ? null
                : _emergencyController.text.trim(),
          );
      if (mounted) {
        context.showSnackBar('Medical preferences saved.');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        context.showSnackBar('Could not save preferences.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Preferences')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'These details help CliniX match you with relevant blood '
                  'support and let responders reach someone you trust.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _bloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items: AppConstants.bloodGroups
                      .map((group) =>
                          DropdownMenuItem(value: group, child: Text(group)))
                      .toList(),
                  onChanged: (value) => setState(() => _bloodGroup = value),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Emergency contact',
                  controller: _emergencyController,
                  hint: '+977 98XXXXXXXX',
                  prefixIcon: Icons.contact_emergency_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v, optional: true),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Save Preferences',
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
