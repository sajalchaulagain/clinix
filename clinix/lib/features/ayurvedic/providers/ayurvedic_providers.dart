import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_ayurvedic_repository.dart';
import '../domain/ayurvedic_repository.dart';

final ayurvedicRepositoryProvider = Provider<AyurvedicRepository>((ref) {
  // BACKEND INTEGRATION: replace with API-backed content once available.
  return MockAyurvedicRepository();
});

/// Symptom text typed on the Baidyek Sathi home screen.
final ayurvedicSymptomQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

final ayurvedicSuggestionsProvider =
    FutureProvider.autoDispose<List<AyurvedicRemedyModel>>((ref) {
  final query = ref.watch(ayurvedicSymptomQueryProvider);
  final repo = ref.watch(ayurvedicRepositoryProvider);
  if (query.trim().isEmpty) {
    return repo.remediesForCategory('Digestion');
  }
  return repo.suggestForSymptoms(query);
});
