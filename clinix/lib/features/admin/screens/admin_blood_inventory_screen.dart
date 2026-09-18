import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/models/blood_stock_model.dart';
import '../providers/admin_providers.dart';

/// Admin CRUD for blood stock. (In production every mutation is re-authorized
/// by the backend; the UI is just a convenient surface.)
class AdminBloodInventoryScreen extends ConsumerWidget {
  const AdminBloodInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(adminInventoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin-add-stock',
        icon: const Icon(Icons.add),
        label: const Text('Add Stock'),
        onPressed: () => _editStock(context, ref, null),
      ),
      body: SafeArea(
        child: AsyncValueView<List<BloodStockModel>>(
          value: inventory,
          loading: const SkeletonList(),
          emptyIcon: Icons.inventory_2_outlined,
          emptyTitle: 'Inventory is empty',
          emptyMessage: 'Add the first blood stock record.',
          onRetry: () => ref.invalidate(adminInventoryProvider),
          builder: (stocks) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              96,
            ),
            itemCount: stocks.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFFE2574C).withValues(alpha: 0.12),
                    child: Text(
                      stock.bloodGroup,
                      style: const TextStyle(
                        color: Color(0xFFE2574C),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  title: Text(stock.hospitalName),
                  subtitle: Text(
                    '${stock.unitsAvailable} units • ${stock.location}\n'
                    'Updated ${DateFormatters.relative(stock.lastUpdated)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Edit stock',
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editStock(context, ref, stock),
                      ),
                      IconButton(
                        tooltip: 'Delete stock',
                        icon: Icon(Icons.delete_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () => _deleteStock(context, ref, stock),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteStock(
    BuildContext context,
    WidgetRef ref,
    BloodStockModel stock,
  ) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete stock record?',
      message:
          '${stock.bloodGroup} at ${stock.hospitalName} will be removed from the inventory.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    final success =
        await ref.read(adminInventoryProvider.notifier).delete(stock.id);
    if (context.mounted) {
      context.showSnackBar(
        success ? 'Stock deleted.' : 'Could not delete the record.',
        isError: !success,
      );
    }
  }

  void _editStock(
    BuildContext context,
    WidgetRef ref,
    BloodStockModel? existing,
  ) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => _StockEditDialog(existing: existing),
    ).then((saved) async {
      if (saved is BloodStockModel) {
        final success =
            await ref.read(adminInventoryProvider.notifier).upsert(saved);
        if (context.mounted) {
          context.showSnackBar(
            success ? 'Stock saved.' : 'Could not save the record.',
            isError: !success,
          );
        }
      }
    });
  }
}

class _StockEditDialog extends StatefulWidget {
  const _StockEditDialog({this.existing});

  final BloodStockModel? existing;

  @override
  State<_StockEditDialog> createState() => _StockEditDialogState();
}

class _StockEditDialogState extends State<_StockEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hospitalController;
  late final TextEditingController _locationController;
  late final TextEditingController _unitsController;
  String? _bloodGroup;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _hospitalController = TextEditingController(text: existing?.hospitalName ?? '');
    _locationController = TextEditingController(text: existing?.location ?? '');
    _unitsController =
        TextEditingController(text: '${existing?.unitsAvailable ?? ''}');
    _bloodGroup = existing?.bloodGroup;
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _locationController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final existing = widget.existing;
    Navigator.of(context).pop(
      BloodStockModel(
        id: existing?.id ?? '',
        bloodGroup: _bloodGroup!,
        hospitalName: _hospitalController.text.trim(),
        location: _locationController.text.trim(),
        unitsAvailable: int.parse(_unitsController.text),
        lastUpdated: existing?.lastUpdated ?? DateTime.now(),
        hospitalId: existing?.hospitalId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Stock' : 'Edit Stock'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: AppConstants.bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                validator: Validators.bloodGroup,
                onChanged: (value) => setState(() => _bloodGroup = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Hospital',
                controller: _hospitalController,
                validator: Validators.hospitalName,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Location',
                controller: _locationController,
                validator: Validators.location,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Units available',
                controller: _unitsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.units,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
