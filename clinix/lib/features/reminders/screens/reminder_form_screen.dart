import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/reminder_model.dart';
import '../providers/reminder_providers.dart';

/// Add / edit reminder. Times are stored as "HH:mm" strings (24h).
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, this.existing});

  final ReminderModel? existing;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;

  late String _frequency;
  late List<String> _times;
  late DateTime _startDate;
  DateTime? _endDate;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.medicineName ?? '');
    _dosageController = TextEditingController(text: existing?.dosage ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _frequency = existing?.frequency ?? AppConstants.reminderFrequencies.first;
    _times = [...(existing?.times ?? const ['08:00'])];
    _startDate = existing?.startDate ?? DateTime.now();
    _endDate = existing?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index) async {
    final parts = _times[index].split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
    );
    if (picked == null) return;
    final hhmm =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _times[index] = hhmm);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  /// Frequency presets map to a suggested number of dose times.
  int get _suggestedTimeCount => switch (_frequency) {
        'Twice daily' => 2,
        'Three times daily' => 3,
        'Weekly' => 1,
        _ => 1,
      };

  void _onFrequencyChanged(String? value) {
    if (value == null) return;
    setState(() {
      _frequency = value;
      final target = _suggestedTimeCount;
      const defaults = ['08:00', '14:00', '20:00'];
      while (_times.length < target) {
        _times.add(defaults[_times.length % defaults.length]);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_times.isEmpty) {
      context.showSnackBar('Add at least one reminder time.', isError: true);
      return;
    }
    final existing = widget.existing;
    final reminder = ReminderModel(
      id: existing?.id ?? 'rem-${DateTime.now().millisecondsSinceEpoch}',
      medicineName: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequency,
      times: _times,
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isEnabled: existing?.isEnabled ?? true,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    final success = await ref
        .read(reminderListProvider.notifier)
        .save(reminder, isEdit: _isEdit);
    if (!mounted) return;
    if (success) {
      context.showSnackBar(
        _isEdit ? 'Reminder updated.' : 'Reminder created — notifications scheduled.',
      );
      Navigator.of(context).pop();
    } else {
      context.showSnackBar('Could not save the reminder.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit Reminder' : 'Add Reminder')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Medicine name',
                  controller: _nameController,
                  hint: 'e.g. Paracetamol',
                  prefixIcon: Icons.medication_outlined,
                  validator: Validators.medicineName,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Dosage',
                  controller: _dosageController,
                  hint: 'e.g. 500mg, 1 tablet',
                  prefixIcon: Icons.science_outlined,
                  validator: Validators.dosage,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: AppConstants.reminderFrequencies
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: _onFrequencyChanged,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reminder times', style: theme.textTheme.titleMedium),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add time'),
                      onPressed: () =>
                          setState(() => _times.add('08:00')),
                    ),
                  ],
                ),
                ...List.generate(_times.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.alarm, size: 18),
                            label: Text(
                              DateFormatters.reminderTime(_times[index]),
                              style: theme.textTheme.titleMedium,
                            ),
                            onPressed: () => _pickTime(index),
                          ),
                        ),
                        if (_times.length > 1)
                          IconButton(
                            tooltip: 'Remove time',
                            icon: Icon(Icons.remove_circle_outline,
                                color: context.colors.error),
                            onPressed: () =>
                                setState(() => _times.removeAt(index)),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: Text('Start: ${DateFormatters.date(_startDate)}'),
                        onPressed: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        label: Text(
                          _endDate == null
                              ? 'End: none'
                              : 'End: ${DateFormatters.date(_endDate!)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                if (_endDate != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _endDate = null),
                      child: const Text('Remove end date'),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Notes (optional)',
                  controller: _notesController,
                  hint: 'e.g. Take after food',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: _isEdit ? 'Save Changes' : 'Create Reminder',
                  icon: Icons.alarm_add_outlined,
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
