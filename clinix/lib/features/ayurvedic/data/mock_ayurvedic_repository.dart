import '../domain/ayurvedic_repository.dart';

/// ⚠️ MOCK — traditional wellness content for UI development.
class MockAyurvedicRepository implements AyurvedicRepository {
  static const _remedies = [
    AyurvedicRemedyModel(
      id: 'ay-1',
      title: 'Ginger (Aduwa) Tea',
      category: 'Digestion',
      description:
          'Fresh ginger steeped in hot water, sometimes with a little honey.',
      traditionalUse:
          'Traditionally used before meals to kindle digestion (agni) and ease heaviness after eating.',
      precautions:
          'May not suit very sensitive stomachs in large amounts; ask a practitioner if you take blood thinners.',
    ),
    AyurvedicRemedyModel(
      id: 'ay-2',
      title: 'Tulsi (Holy Basil) Infusion',
      category: 'Immunity',
      description:
          'Tulsi leaves steeped as a warm herbal infusion, taken in the morning.',
      traditionalUse:
          'A classic seasonal wellness drink in Ayurvedic tradition, especially during weather changes.',
      precautions:
          'If pregnant, breastfeeding, or on medication, confirm suitability with a qualified practitioner.',
    ),
    AyurvedicRemedyModel(
      id: 'ay-3',
      title: 'Turmeric Milk (Haldi Doodh)',
      category: 'Sleep & Recovery',
      description:
          'Warm milk with a pinch of turmeric and black pepper before bed.',
      traditionalUse:
          'Traditionally taken in the evening to support rest and recovery.',
      precautions:
          'Avoid if you have milk intolerance; turmeric may interact with some medicines.',
    ),
    AyurvedicRemedyModel(
      id: 'ay-4',
      title: 'Triphala',
      category: 'Digestion',
      description:
          'A classical blend of three fruits (amalaki, bibhitaki, haritaki) taken as powder or tablets.',
      traditionalUse:
          'Traditionally used for gentle, regular bowel habits and digestive balance.',
      precautions:
          'Quality varies by source; avoid overuse. Not a substitute for medical care for ongoing issues.',
    ),
    AyurvedicRemedyModel(
      id: 'ay-5',
      title: 'Ashwagandha',
      category: 'Stress & Energy',
      description:
          'An adaptogenic root used in Ayurvedic practice, typically as powder with warm milk or water.',
      traditionalUse:
          'Traditionally used to support calm energy and resilience to stress.',
      precautions:
          'Not advised in pregnancy; may interact with thyroid or sedative medicines — check first.',
    ),
    AyurvedicRemedyModel(
      id: 'ay-6',
      title: 'Steam Inhalation with Ajwain',
      category: 'Seasonal Care',
      description:
          'Warm steam inhalation with carom seeds (ajwain) added to the water.',
      traditionalUse:
          'A traditional comfort practice for seasonal stuffiness and cough.',
      precautions:
          'Careful with hot steam (burn risk). Persistent cough or fever needs medical attention.',
    ),
  ];

  static const keywords = <String, List<String>>{
    'digest': ['ay-1', 'ay-4'],
    'stomach': ['ay-1', 'ay-4'],
    'sleep': ['ay-3', 'ay-5'],
    'stress': ['ay-5', 'ay-3'],
    'cold': ['ay-2', 'ay-6'],
    'cough': ['ay-6', 'ay-2'],
    'immunity': ['ay-2', 'ay-5'],
    'energy': ['ay-5'],
  };

  AyurvedicRemedyModel _byId(String id) =>
      _remedies.firstWhere((remedy) => remedy.id == id);

  @override
  Future<List<AyurvedicRemedyModel>> suggestForSymptoms(String symptoms) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final text = symptoms.toLowerCase();
    final matched = <String>{};
    keywords.forEach((key, ids) {
      if (text.contains(key)) matched.addAll(ids);
    });
    if (matched.isEmpty) return _remedies.take(3).toList();
    return matched.map(_byId).toList();
  }

  @override
  Future<List<AyurvedicRemedyModel>> remediesForCategory(String category) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _remedies.where((r) => r.category == category).toList();
  }
}
