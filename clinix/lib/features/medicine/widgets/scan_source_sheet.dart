import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_dimensions.dart';

/// Bottom sheet to choose camera vs gallery when adding a medicine photo.
Future<ImageSource?> showScanSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add medicine photo', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Use a clear, well-lit photo of the package or label.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.photo_camera_outlined,
                      label: 'Camera',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            children: [
              Icon(icon, size: 36, color: colors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
