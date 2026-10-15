import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../app/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/chat_message_model.dart';
import '../data/api_ai_repository.dart';
import '../data/mock_ai_repository.dart';
import '../domain/ai_repository.dart';

/// Returns the real FastAPI-backed repository when USE_MOCK_DATA=false,
/// or when USE_LIVE_AI=true (allows live AI while keeping other mocks).
/// Otherwise returns the mock for offline/UI development.
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  if (!AppConfig.useMockData || AppConfig.useLiveAi) {
    return ApiAiRepository(ref.read(apiClientProvider));
  }
  return MockAiRepository();
});

/// Immutable UI state for a chat session.
class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.errorMessage,
  });

  final List<ChatMessageModel> messages;
  final bool isTyping;
  final String? errorMessage;

  bool get hasUserMessages => messages.any((m) => m.isFromUser);

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, errorMessage];
}

/// Owns one conversation (per assistant persona). Kept as a family provider so
/// Upachar Sathi and Baidyek Sathi keep separate histories in a session.
class ChatController extends AutoDisposeFamilyNotifier<ChatState, AiPersona> {
  int _localId = 0;

  @override
  ChatState build(AiPersona arg) {
    // Seed with the persona disclaimer so safety copy is always visible.
    final disclaimer = ChatMessageModel(
      id: 'disclaimer-${arg.name}',
      text: arg == AiPersona.upachar
          ? AppStrings.aiDisclaimer
          : AppStrings.ayurvedicDisclaimer,
      sender: ChatSender.system,
      createdAt: DateTime.now(),
      isDisclaimer: true,
    );
    return ChatState(messages: [disclaimer]);
  }

  Future<void> send(String text, {String? attachmentPath}) async {
    if (state.isTyping) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachmentPath == null) return;

    final userMessage = ChatMessageModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}-${_localId++}',
      text: trimmed.isEmpty ? '(photo attached)' : trimmed,
      sender: ChatSender.user,
      createdAt: DateTime.now(),
      attachmentName: attachmentPath,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      clearError: true,
    );

    try {
      final reply = await ref.read(aiRepositoryProvider).sendMessage(
            persona: arg,
            history: state.messages,
            attachmentPath: attachmentPath,
          );
      state = state.copyWith(
        messages: [...state.messages, reply],
        isTyping: false,
      );
    } catch (e) {
      String errorMessage;

      if (e is UnauthorizedException) {
        debugPrint('[ChatController] 401 Unauthorized — no valid auth token.');
        errorMessage = 'Sign in required for AI. Please sign out and sign back in.';
      } else if (e is TimeoutAppException) {
        debugPrint('[ChatController] Request timed out.');
        errorMessage =
            'The AI backend is waking up (free tier). Please wait 30 s and try again.';
      } else if (e is ServerException && (e.statusCode == 502 || e.statusCode == 503)) {
        debugPrint('[ChatController] Backend ${e.statusCode} — likely cold start.');
        errorMessage =
            'The AI backend is starting up. Please try again in a moment.';
      } else if (e is NoNetworkException) {
        debugPrint('[ChatController] No network.');
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e is DioException) {
        final status = e.response?.statusCode;
        final body = e.response?.data;
        debugPrint('[ChatController] DioException [${e.type}]: ${e.message}');
        debugPrint('[ChatController] StatusCode: $status');
        debugPrint('[ChatController] Response body: $body');
        if (status == 401) {
          errorMessage =
              'Sign in required for AI. Please sign out and sign back in.';
        } else if (status == 502 || status == 503) {
          errorMessage =
              'The AI backend is starting up. Please try again in a moment.';
        } else {
          errorMessage =
              'The assistant could not reply right now. Please try again.';
        }
      } else {
        debugPrint('[ChatController] Unexpected error: $e');
        errorMessage = 'The assistant could not reply right now. Please try again.';
      }

      state = state.copyWith(
        isTyping: false,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> clear() async {
    // Rebuild state to restore only the disclaimer message.
    state = build(arg);
  }
}

final chatControllerProvider = AutoDisposeNotifierProviderFamily<ChatController,
    ChatState, AiPersona>(ChatController.new);

final aiSuggestionsProvider =
    Provider.family<List<String>, AiPersona>((ref, persona) {
  return ref.watch(aiRepositoryProvider).suggestionsFor(persona);
});
