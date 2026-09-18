import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (message.isDisclaimer || message.sender == ChatSender.system) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined,
                size: 18, color: colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message.text,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.onPrimaryContainer),
              ),
            ),
          ],
        ),
      );
    }

    final isUser = message.isFromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.all(AppSpacing.sm + 4),
          decoration: BoxDecoration(
            color: isUser ? colors.primary : colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.lg),
              topRight: const Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
              bottomRight:
                  Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.attachmentName != null)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (isUser ? Colors.white : colors.primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 16,
                          color: isUser ? Colors.white : colors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          message.attachmentName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUser ? Colors.white : colors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser ? Colors.white : colors.onSurface,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateFormatters.time(message.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
