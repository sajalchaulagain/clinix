import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../providers/admin_providers.dart';

/// Compose + (mock) broadcast a notification to all users.
///
/// BACKEND INTEGRATION: FastAPI will target FCM topics; targeting and delivery
/// receipts are server responsibilities.
class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref.read(adminActionControllerProvider.notifier).broadcast(
          _titleController.text.trim(),
          _bodyController.text.trim(),
        );
    if (!mounted) return;
    context.showSnackBar(
      success
          ? 'Notification broadcast queued (demo).'
          : 'Could not broadcast the notification.',
      isError: !success,
    );
    if (success) {
      _titleController.clear();
      _bodyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminActionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Notification')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DisclaimerBanner(
                  text: 'Broadcasts reach all CliniX users. Use for important, '
                      'infrequent updates only — never ads or spam.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Title',
                  controller: _titleController,
                  hint: 'e.g. Blood camp this Saturday',
                  validator: (v) => Validators.required(v, fieldName: 'Title'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Message',
                  controller: _bodyController,
                  hint: 'Write the notification content...',
                  maxLines: 4,
                  validator: (v) => Validators.required(v, fieldName: 'Message'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Broadcast to all users',
                  icon: Icons.campaign_outlined,
                  isLoading: isLoading,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
