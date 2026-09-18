import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../domain/ai_repository.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/emergency_dialog.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

/// Unified chat screen for both assistants:
/// Upachar Sathi (general) and Baidyek Sathi (ayurvedic).
class AiChatScreen extends ConsumerWidget {
  const AiChatScreen({super.key, required this.persona});

  final AiPersona persona;

  String get _title => persona == AiPersona.upachar
      ? AppConstants.aiAssistantName
      : AppConstants.ayurvedicAssistantName;

  String get _subtitle => persona == AiPersona.upachar
      ? 'AI health information assistant'
      : 'Ayurvedic wellness assistant';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatControllerProvider(persona));
    final suggestions = ref.watch(aiSuggestionsProvider(persona));
    final theme = context.theme;
    final colors = context.colors;

    ref.listen(chatControllerProvider(persona), (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        context.showSnackBar(next.errorMessage!, isError: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title),
            Text(_subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Emergency guidance',
            icon: Icon(Icons.emergency_outlined, color: colors.error),
            onPressed: () => showEmergencyGuidance(context),
          ),
          IconButton(
            tooltip: 'Clear conversation',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showConfirmationDialog(
                context: context,
                title: 'Clear conversation?',
                message: 'This removes all messages in this chat.',
                confirmLabel: 'Clear',
                isDestructive: true,
              );
              if (confirmed) {
                ref.read(chatControllerProvider(persona).notifier).clear();
                if (context.mounted) {
                  context.showSnackBar('Conversation cleared.');
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount:
                  chat.messages.length + (chat.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (chat.isTyping && index == 0) {
                  return const TypingIndicator();
                }
                final offset = chat.isTyping ? 1 : 0;
                final message = chat.messages[
                    chat.messages.length - 1 - (index - offset)];
                return MessageBubble(message: message);
              },
            ),
          ),

          // Suggested starter questions (hidden after first user message).
          if (!chat.hasUserMessages)
            Container(
              width: double.infinity,
              color: colors.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: suggestions
                    .map(
                      (question) => ActionChip(
                        label: Text(question,
                            style: theme.textTheme.bodySmall),
                        onPressed: () => ref
                            .read(chatControllerProvider(persona).notifier)
                            .send(question),
                      ),
                    )
                    .toList(),
              ),
            ),

          ChatInputBar(
            enabled: !chat.isTyping,
            hint: persona == AiPersona.upachar
                ? 'Type your health question...'
                : 'Ask about Ayurvedic wellness...',
            onSend: (text) =>
                ref.read(chatControllerProvider(persona).notifier).send(text),
            onAttachImage: (image) => ref
                .read(chatControllerProvider(persona).notifier)
                .send('Please look at this photo.', attachmentPath: image.name),
          ),
        ],
      ),
    );
  }
}
