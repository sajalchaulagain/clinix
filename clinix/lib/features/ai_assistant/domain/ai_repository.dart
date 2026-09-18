import '../../../shared/models/chat_message_model.dart';

/// Persona for AI conversations so both assistants share one chat engine
/// with distinct branding, prompts and mock responses.
enum AiPersona {
  upachar,
  baidyek,
}

/// Contract for AI assistant conversations.
///
/// Flow: UI -> ChatController -> AiRepository -> ApiService -> FastAPI backend
/// (OpenRouter). NEVER call OpenRouter directly from Flutter — the key lives
/// only on the backend.
abstract class AiRepository {
  /// Sends the conversation so far and returns the assistant's reply message.
  ///
  /// [attachmentPath] is a local image path when the user attached a photo;
  /// the backend implementation will upload it as multipart data.
  Future<ChatMessageModel> sendMessage({
    required AiPersona persona,
    required List<ChatMessageModel> history,
    String? attachmentPath,
  });

  /// Suggested starter questions per persona.
  List<String> suggestionsFor(AiPersona persona);
}
