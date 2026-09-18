import '../../../shared/models/chat_message_model.dart';
import '../domain/ai_repository.dart';

/// ⚠️ MOCK — UI development only.
///
/// Returns canned, safety-first demo responses with a simulated delay so the
/// typing indicator flow is exercised. The real implementation calls the
/// FastAPI backend, which relays to OpenRouter.
class MockAiRepository implements AiRepository {
  int _counter = 0;

  @override
  List<String> suggestionsFor(AiPersona persona) {
    return switch (persona) {
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
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required AiPersona persona,
    required List<ChatMessageModel> history,
    String? attachmentPath,
  }) async {
    // Simulate network + AI thinking time.
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final lastUserText = history
        .where((m) => m.isFromUser)
        .map((m) => m.text)
        .lastOrNull
        ?.toLowerCase() ??
        '';
    _counter++;

    final body = switch (persona) {
      AiPersona.upachar => _upacharReply(lastUserText, attachmentPath),
      AiPersona.baidyek => _baidyekReply(lastUserText, attachmentPath),
    };

    return ChatMessageModel(
      id: 'ai-${DateTime.now().millisecondsSinceEpoch}-$_counter',
      text: body,
      sender: ChatSender.ai,
      createdAt: DateTime.now(),
    );
  }

  String _upacharReply(String query, String? attachment) {
    if (attachment != null) {
      return 'I received your image "$attachment". Once the CliniX backend is '
          'connected, I can analyze medicine photos and reports.\n\n'
          'For now, here is general guidance: never start, stop, or change a '
          'medicine based on a photo alone — consult a pharmacist or doctor. '
          'If you feel unwell right now, describe your main symptom and I will '
          'share general information.';
    }
    if (query.contains('headache')) {
      return 'Headaches have many possible causes — dehydration, eye strain, '
          'stress, poor sleep, or skipped meals are common everyday ones.\n\n'
          'General steps people often find helpful:\n'
          '• Drink water and rest in a quiet, dim room\n'
          '• Limit screen time for a while\n'
          '• Eat something light if you skipped a meal\n\n'
          'Seek medical care urgently if the headache is sudden and severe, '
          'follows a head injury, or comes with fever, stiff neck, confusion, '
          'weakness, or vision changes.';
    }
    if (query.contains('cold') || query.contains('fever')) {
      return 'Common cold symptoms usually include a runny or stuffy nose, '
          'sneezing, sore throat, mild cough and low-grade tiredness. Rest, '
          'fluids and warm soups are general comfort measures.\n\n'
          'Consider seeing a doctor if symptoms last beyond 10 days, you have '
          'high fever, breathing difficulty, or severe ear/sinus pain. Antibiotics '
          'do not treat viral colds — please do not self-medicate with them.';
    }
    if (query.contains('medicine') || query.contains('tablet')) {
      return 'Good things to know before taking any medicine:\n'
          '• Confirm the correct dose and timing with a pharmacist or doctor\n'
          '• Check for allergies and possible interactions with what you '
          'already take\n'
          '• Take it with food or water if advised, and finish prescribed courses\n'
          '• Never share prescription medicines\n\n'
          'You can also scan the medicine package with the CliniX Medicine '
          'Scanner for detailed information.';
    }
    return 'Thanks for your question (demo reply $_counter).\n\n'
        'In the live version I will provide evidence-informed, general health '
        'information through the CliniX backend. Meanwhile:\n'
        '• Describe your main symptom or question in a sentence\n'
        '• I can share general information and when-to-see-a-doctor guidance\n\n'
        'Remember: I provide information, not diagnosis. For anything severe '
        'or worrying, please consult a qualified healthcare professional.';
  }

  String _baidyekReply(String query, String? attachment) {
    if (query.contains('digest')) {
      return 'In Ayurvedic tradition, digestion (agni) is considered central '
          'to well-being. Traditionally suggested habits include:\n\n'
          '• Warm water or ginger tea before meals\n'
          '• Eating at regular times without rushing\n'
          '• Favoring freshly cooked, seasonal food\n\n'
          'These are traditional wellness practices, not medical treatments. '
          'If you have ongoing digestive problems, please also consult a doctor.';
    }
    if (query.contains('sleep')) {
      return 'Ayurveda traditionally suggests a calming evening routine for '
          'better sleep:\n\n'
          '• Warm milk with a pinch of nutmeg (if suitable for you)\n'
          '• Reducing screens and bright light before bed\n'
          '• Gentle oil massage of the feet\n\n'
          'Persistent sleep problems deserve professional evaluation — '
          'traditional tips are supportive, not a substitute for care.';
    }
    return 'Namaste! (demo reply $_counter) Baidyek Sathi shares traditional '
        'Ayurvedic wellness information — herbs, routines and seasonal habits '
        'drawn from classical practice.\n\n'
        'These suggestions are not medically validated treatments. Use them as '
        'complementary lifestyle knowledge and consult a qualified practitioner, '
        'especially if you take medicines, are pregnant, or have a condition.';
  }
}
