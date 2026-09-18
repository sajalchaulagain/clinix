import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_dimensions.dart';

/// Bottom input: text field + attach (image) + voice placeholder + send.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onAttachImage,
    this.enabled = true,
    this.hint = 'Type your health question...',
  });

  final void Function(String text) onSend;
  final void Function(XFile image) onAttachImage;
  final bool enabled;
  final String hint;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  Future<void> _pickImage() async {
    try {
      final image =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (image != null) widget.onAttachImage(image);
    } catch (_) {
      // Denied permissions etc. land here; UI shows a snackbar in caller.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Attach image',
              onPressed: widget.enabled ? _pickImage : null,
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 4,
                    vertical: AppSpacing.sm + 2,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Voice input (coming soon)',
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Voice input will be available in a future update.'),
                    ),
                  );
              },
              icon: const Icon(Icons.mic_none_outlined),
            ),
            Semantics(
              button: true,
              label: 'Send message',
              child: Material(
                color: colors.primary,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: widget.enabled ? _send : null,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
