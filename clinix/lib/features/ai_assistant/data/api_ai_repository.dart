
import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/api_providers.dart';
import '../../../shared/models/chat_message_model.dart';
import '../domain/ai_repository.dart';

/// Live implementation — calls the FastAPI backend, which in turn calls
/// OpenRouter (the key never touches the Flutter app).
///
/// Request body mirrors [ChatRequest] in backend/app/schemas/ai.py.
/// Response mirrors [ChatMessage] in the same schema.
class ApiAiRepository implements AiRepository {
  ApiAiRepository(this._factory);

  final ApiClientFactory _factory;

  @override
  List<String> suggestionsFor(AiPersona persona) => switch (persona) {
        AiPersona.upachar => [
            'Why do I have a headache?',
            'What should I know before taking this medicine?',
            'What are common cold symptoms?',
            'How much water should I drink daily?',
          ],
        AiPersona.baidyek => [
            'Ayurvedic tips for better digestion',
            'Herbs traditionally used for better sleep',
            'What is a balanced Ayurvedic morning routine?',
            'Traditional remedies for seasonal cough',
          ],
      };

  @override
  Future<ChatMessageModel> sendMessage({
    required AiPersona persona,
    required List<ChatMessageModel> history,
    String? attachmentPath,
  }) async {
    final client = await _factory.build();

    final endpoint = persona == AiPersona.upachar
        ? ApiEndpoints.aiChat
        : ApiEndpoints.ayurvedicChat;

    // The backend expects the full history so it can build conversation context.
    // We omit disclaimer messages (system role) — the backend prompt already
    // embeds safety framing.
    final historyJson = history
        .where((m) => !m.isDisclaimer)
        .map((m) => m.toJson())
        .toList();

    final body = <String, dynamic>{
      'history': historyJson,
      // Base64-encode the image bytes if an attachment was selected.
      // Currently attachmentPath is a local XFile.path; for web it's a blob URL.
      // The backend accepts this as optional; if null the field is omitted.
      if (attachmentPath != null) 'attachment_base64': attachmentPath,
    };

    final response = await client.post<Map<String, dynamic>>(
      endpoint,
      data: body,
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from AI service.');
    }

    return ChatMessageModel.fromJson(data);
  }
}
