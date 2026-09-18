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
import '../../../shared/models/blood_request_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/blood_providers.dart';

/// Blood request form + the user's recent requests list.
class BloodRequestScreen extends ConsumerStatefulWidget {
  const BloodRequestScreen({super.key, this.initialBloodGroup});

  final String? initialBloodGroup;

  @override
  ConsumerState<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends ConsumerState<BloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _locationController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _reasonController = TextEditingController();
  String? _bloodGroup;
  BloodRequestUrgency _urgency = BloodRequestUrgency.normal;

  @override
  void initState() {
    super.initState();
    _bloodGroup = widget.initialBloodGroup;
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _locationController.dispose();
    _unitsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(currentUserProvider);
    final request = BloodRequestModel(
      id: '',
      requesterName: user?.fullName ?? 'CliniX User',
      bloodGroup: _bloodGroup!,
      units: int.parse(_unitsController.text),
      hospitalName: _hospitalController.text.trim(),
      location: _locationController.text.trim(),
      status: BloodRequestStatus.pending,
      createdAt: DateTime.now(),
      urgency: _urgency,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    final success =
        await ref.read(bloodRequestControllerProvider.notifier).submit(request);
    if (!mounted) return;
    if (success) {
      context.showSnackBar('Blood request submitted. Hospitals are notified (demo).');
      _formKey.currentState?.reset();
      setState(() {
        _bloodGroup = null;
        _urgency = BloodRequestUrgency.normal;
        _unitsController.text = '1';
        _reasonController.clear();
      });
    } else {
      final error = ref.read(bloodRequestControllerProvider).asError?.error;
      context.showSnackBar(
        error is AppException ? error.message : 'Could not submit the request.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final isSubmitting = ref.watch(bloodRequestControllerProvider).isLoading;
    final myRequests = ref.watch(myBloodRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Form ----
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group *',
                        prefixIcon: Icon(Icons.bloodtype_outlined),
                      ),
                      items: AppConstants.bloodGroups
                          .map((group) => DropdownMenuItem(
                              value: group, child: Text(group)))
                          .toList(),
                      validator: Validators.bloodGroup,
                      onChanged: (value) =>
                          setState(() => _bloodGroup = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Units needed',
                      controller: _unitsController,
                      hint: 'e.g. 2',
                      prefixIcon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      validator: Validators.units,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Hospital',
                      controller: _hospitalController,
                      hint: 'e.g. Patan Hospital',
                      prefixIcon: Icons.local_hospital_outlined,
                      validator: Validators.hospitalName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Location',
                      controller: _locationController,
                      hint: 'e.g. Lalitpur',
                      prefixIcon: Icons.location_on_outlined,
                      validator: Validators.location,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Reason (optional)',
                      controller: _reasonController,
                      hint: 'e.g. Scheduled surgery, accident...',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Urgency', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<BloodRequestUrgency>(
                      segments: const [
                        ButtonSegment(
                            value: BloodRequestUrgency.normal,
                            label: Text('Normal')),
                        ButtonSegment(
                            value: BloodRequestUrgency.urgent,
                            label: Text('Urgent')),
                        ButtonSegment(
                            value: BloodRequestUrgency.critical,
                            label: Text('Critical')),
                      ],
                      selected: {_urgency},
                      onSelectionChanged: (selection) =>
                          setState(() => _urgency = selection.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Submit Request',
                      icon: Icons.water_drop_outlined,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'My Recent Requests'),
              AsyncValueView(
                value: myRequests,
                emptyIcon: Icons.inbox_outlined,
                emptyTitle: 'No requests yet',
                emptyMessage:
                    'Your submitted blood requests will appear here.',
                onRetry: () => ref.invalidate(myBloodRequestsProvider),
                builder: (requests) => Column(
                  children: [
                    for (final request in requests)
                      Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.errorContainer,
                            child: Text(
                              request.bloodGroup,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onErrorContainer,
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
                            '${request.location} • ${request.urgency.name}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: _statusChip(context, request.status),
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

  Widget _statusChip(BuildContext context, BloodRequestStatus status) {
    final theme = context.theme;
    final (label, color) = switch (status) {
      BloodRequestStatus.pending => ('Pending', Colors.orange),
      BloodRequestStatus.approved => ('Approved', Colors.green),
      BloodRequestStatus.fulfilled => ('Fulfilled', Colors.blue),
      BloodRequestStatus.cancelled => ('Cancelled', Colors.grey),
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
