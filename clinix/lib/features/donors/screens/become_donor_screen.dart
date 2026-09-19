import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../providers/donor_providers.dart';

/// "Become a Donor" registration form.
class BecomeDonorScreen extends ConsumerStatefulWidget {
  const BecomeDonorScreen({super.key});

  @override
  ConsumerState<BecomeDonorScreen> createState() => _BecomeDonorScreenState();
}

class _BecomeDonorScreenState extends ConsumerState<BecomeDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  String? _bloodGroup;
  DateTime? _lastDonation;
  bool _isAvailable = true;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickLastDonation() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 120)),
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'When did you last donate blood?',
    );
    if (picked != null) setState(() => _lastDonation = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success =
        await ref.read(donorActionControllerProvider.notifier).register(
              bloodGroup: _bloodGroup!,
              location: _locationController.text.trim(),
              lastDonationDate: _lastDonation,
              isAvailable: _isAvailable,
            );
    if (!mounted) return;
    if (success) {
      context.showSnackBar('You are registered as a donor. Thank you!');
      Navigator.of(context).pop();
    } else {
      context.showSnackBar('Registration failed. Please try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isLoading = ref.watch(donorActionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Become a Donor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2574C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_outline,
                          color: Color(0xFFE2574C)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'One donation can save up to three lives. Your contact '
                          'details stay private until you choose to share them.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _bloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group *',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items: AppConstants.bloodGroups
                      .map((group) =>
                          DropdownMenuItem(value: group, child: Text(group)))
                      .toList(),
                  validator: Validators.bloodGroup,
                  onChanged: (value) => setState(() => _bloodGroup = value),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Your location',
                  controller: _locationController,
                  hint: 'e.g. Kathmandu',
                  prefixIcon: Icons.location_on_outlined,
                  validator: Validators.location,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _pickLastDonation,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    _lastDonation == null
                        ? 'Last donation date (optional)'
                        : 'Last donation: ${_lastDonation!.day}/${_lastDonation!.month}/${_lastDonation!.year}',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available to donate'),
                  subtitle: const Text(
                      'Show me in searches when someone needs blood'),
                  value: _isAvailable,
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'General guidance: whole-blood donors usually wait about 3 '
                  'months between donations. Eligibility is always confirmed '
                  'by the blood bank.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Register as Donor',
                  icon: Icons.volunteer_activism_outlined,
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
