import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/blood_donation_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/blood_providers.dart';

/// Screen for offering to donate blood (submit request + manage my requests).
class BloodDonationRequestScreen extends ConsumerStatefulWidget {
  const BloodDonationRequestScreen({super.key});

  @override
  ConsumerState<BloodDonationRequestScreen> createState() =>
      _BloodDonationRequestScreenState();
}

class _BloodDonationRequestScreenState
    extends ConsumerState<BloodDonationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _donorNameController;
  final _phoneController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String? _bloodGroup;
  int _units = 1;
  late DateTime _preferredDate;
  bool _eligibilityChecked = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    _donorNameController =
        TextEditingController(text: currentUser?.fullName ?? '');
    _preferredDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPreferredDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      helpText: 'Preferred Donation Date',
    );
    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_eligibilityChecked) {
      context.showSnackBar('Please confirm your eligibility to donate.',
          isError: true);
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final donation = BloodDonationModel(
      id: '',
      userId: currentUser?.id ?? '',
      donorName: _donorNameController.text.trim(),
      phone: _phoneController.text.trim(),
      bloodGroup: _bloodGroup!,
      units: _units,
      hospitalName: _hospitalController.text.trim(),
      location: _locationController.text.trim(),
      status: DonationRequestStatus.pending,
      createdAt: DateTime.now(),
      preferredDate: _preferredDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await ref
        .read(donationRequestControllerProvider.notifier)
        .submit(donation);
    if (!mounted) return;

    if (success) {
      context.showSnackBar('Blood donation offer submitted successfully.');
      _phoneController.clear();
      _hospitalController.clear();
      _locationController.clear();
      _notesController.clear();
      setState(() {
        _bloodGroup = null;
        _units = 1;
        _preferredDate = DateTime.now().add(const Duration(days: 7));
        _eligibilityChecked = false;
      });
    } else {
      final error = ref.read(donationRequestControllerProvider).asError?.error;
      context.showSnackBar(
        error is AppException
            ? error.message
            : 'Could not submit donation request.',
        isError: true,
      );
    }
  }

  Future<void> _cancelRequest(String id) async {
    final success =
        await ref.read(donationRequestControllerProvider.notifier).cancel(id);
    if (!mounted) return;

    if (success) {
      context.showSnackBar('Donation request cancelled.');
    } else {
      final error = ref.read(donationRequestControllerProvider).asError?.error;
      context.showSnackBar(
        error is AppException
            ? error.message
            : 'Could not cancel donation request.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final isSubmitting = ref.watch(donationRequestControllerProvider).isLoading;
    final myRequests = ref.watch(myDonationRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Donate Blood')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Donor Name *',
                      controller: _donorNameController,
                      hint: 'Your full name',
                      prefixIcon: Icons.person_outlined,
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Phone Number *',
                      controller: _phoneController,
                      hint: 'e.g. +977-9800000000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => Validators.phone(value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _bloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group *',
                        prefixIcon: Icon(Icons.bloodtype_outlined),
                      ),
                      items: AppConstants.bloodGroups
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      validator: Validators.bloodGroup,
                      onChanged: (value) => setState(() => _bloodGroup = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Units to donate',
                            style: theme.textTheme.titleMedium),
                        Row(
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.remove),
                              onPressed: _units > 1
                                  ? () => setState(() => _units--)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                '$_units',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.outlined(
                              icon: const Icon(Icons.add),
                              onPressed: _units < 2
                                  ? () => setState(() => _units++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Preferred Hospital *',
                      controller: _hospitalController,
                      hint: 'e.g. Patan Hospital',
                      prefixIcon: Icons.local_hospital_outlined,
                      validator: Validators.hospitalName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Location / Address *',
                      controller: _locationController,
                      hint: 'e.g. Lalitpur',
                      prefixIcon: Icons.location_on_outlined,
                      validator: Validators.location,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _pickPreferredDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        'Preferred Date: ${_preferredDate.day}/${_preferredDate.month}/${_preferredDate.year}',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Notes (optional)',
                      controller: _notesController,
                      hint: 'e.g. Available in afternoon only...',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _eligibilityChecked,
                      onChanged: (val) =>
                          setState(() => _eligibilityChecked = val ?? false),
                      title: Text(
                        'It has been ~3 months since my last donation and I feel healthy today',
                        style: theme.textTheme.bodyMedium,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Submit Donation Offer',
                      icon: Icons.volunteer_activism_outlined,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'My donation requests'),
              AsyncValueView(
                value: myRequests,
                emptyIcon: Icons.inbox_outlined,
                emptyTitle: 'No donation requests yet',
                emptyMessage:
                    'Your submitted blood donation offers will appear here.',
                onRetry: () => ref.invalidate(myDonationRequestsProvider),
                builder: (requests) => Column(
                  children: [
                    for (final request in requests)
                      Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            child: Text(
                              request.bloodGroup,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            '${request.units} unit${request.units > 1 ? 's' : ''} • ${request.hospitalName}',
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${request.location}${request.preferredDate != null ? ' • Date: ${request.preferredDate!.day}/${request.preferredDate!.month}/${request.preferredDate!.year}' : ''}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _statusChip(context, request.status),
                              if (request.status ==
                                  DonationRequestStatus.pending) ...[
                                const SizedBox(width: AppSpacing.xs),
                                IconButton(
                                  icon: const Icon(Icons.cancel_outlined,
                                      color: Colors.red),
                                  tooltip: 'Cancel request',
                                  onPressed: () => _cancelRequest(request.id),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, DonationRequestStatus status) {
    final theme = context.theme;
    final (label, color) = switch (status) {
      DonationRequestStatus.pending => ('Pending', Colors.orange),
      DonationRequestStatus.confirmed => ('Confirmed', Colors.green),
      DonationRequestStatus.completed => ('Completed', Colors.blue),
      DonationRequestStatus.cancelled => ('Cancelled', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
