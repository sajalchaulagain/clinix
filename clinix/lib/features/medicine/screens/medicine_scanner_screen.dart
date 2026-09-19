import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../providers/medicine_providers.dart';
import '../widgets/analysis_loading_view.dart';
import '../widgets/scan_source_sheet.dart';

/// Medicine Scanner: pick 1-4 photos -> analyze -> result.
///
/// Images stay as local [XFile]s. The future ApiMedicineRepository uploads
/// them via multipart to FastAPI (no third-party keys on device).
class MedicineScannerScreen extends ConsumerStatefulWidget {
  const MedicineScannerScreen({super.key});

  @override
  ConsumerState<MedicineScannerScreen> createState() =>
      _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends ConsumerState<MedicineScannerScreen> {
  final _picker = ImagePicker();

  Future<void> _addImages() async {
    final source = await showScanSourceSheet(context);
    if (source == null) return;
    try {
      List<XFile> picked;
      if (source == ImageSource.gallery) {
        picked = await _picker.pickMultiImage(maxWidth: 1600);
      } else {
        final single = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1600,
        );
        picked = single == null ? [] : [single];
      }
      if (picked.isNotEmpty) {
        ref.read(selectedImagesProvider.notifier).addAll(picked);
      }
    } catch (_) {
      if (mounted) {
        context.showSnackBar(
          'Could not access the $source. Please check app permissions.',
          isError: true,
        );
      }
    }
  }

  Future<void> _analyze(List<XFile> images) async {
    await ref.read(scanAnalysisProvider.notifier).analyze(images);
    if (!mounted) return;
    final result = ref.read(scanAnalysisProvider);
    result?.when(
      data: (_) => context.push('/medicine-result'),
      loading: () {},
      error: (error, _) => context.showSnackBar(
        'Analysis failed. Please try again with a clearer photo.',
        isError: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(selectedImagesProvider);
    final analysis = ref.watch(scanAnalysisProvider);
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Scanner'),
        actions: [
          if (images.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(selectedImagesProvider.notifier).clear();
                ref.read(scanAnalysisProvider.notifier).reset();
              },
              child: const Text('Start over'),
            ),
        ],
      ),
      body: SafeArea(
        child: analysis is AsyncLoading
            ? const AnalysisLoadingView()
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: images.isEmpty
                    ? _EmptyScanner(onAdd: _addImages)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Selected medicines (${images.length}/4)',
                              style: theme.textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'You can compare up to 4 medicines in one analysis.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisSpacing: AppSpacing.sm,
                              ),
                              itemCount: images.length +
                                  (images.length < 4 ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= images.length) {
                                  return _AddMoreTile(onTap: _addImages);
                                }
                                final image = images[index];
                                return _ImageTile(
                                  image: image,
                                  label: 'Medicine ${index + 1}',
                                  onRemove: () => ref
                                      .read(selectedImagesProvider.notifier)
                                      .removeAt(index),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: images.length > 1
                                ? 'Analyze ${images.length} medicines'
                                : 'Analyze medicine',
                            icon: Icons.document_scanner_outlined,
                            onPressed: () => _analyze(images),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Analysis is informational only — it is not a '
                            'prescription or diagnosis.',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}

class _EmptyScanner extends StatelessWidget {
  const _EmptyScanner({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.document_scanner_outlined,
              size: 56, color: colors.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Scan a medicine', style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Photograph the medicine package or label to get plain-language '
          'information about uses, precautions, interactions and more.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Add Photo',
          icon: Icons.add_a_photo_outlined,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _AddMoreTile extends StatelessWidget {
  const _AddMoreTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 36, color: colors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text('Add more', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.image,
    required this.label,
    required this.onRemove,
  });

  final XFile image;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List>(
            future: image.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Icon(Icons.error));
              }
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            },
          ),
          Positioned(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Semantics(
              button: true,
              label: 'Remove photo',
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
