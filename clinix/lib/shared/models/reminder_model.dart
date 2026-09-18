import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  const ReminderModel({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    required this.isEnabled,
    this.endDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String medicineName;
  final String dosage;

  /// Human-readable label from [AppConstants.reminderFrequencies].
  final String frequency;

  /// Times of day in "HH:mm" (24h) format, e.g. ['08:00', '20:00'].
  final List<String> times;

  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isEnabled;
  final DateTime? createdAt;

  /// Deterministic notification id per reminder+time so schedules can be
  /// cancelled individually. Stable across app restarts (based on id hash).
  int notificationIdFor(int timeIndex) =>
      (id.hashCode & 0x7fffffff) % 100000 * 10 + timeIndex;

  bool get isActiveToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDate;
    if (today.isBefore(start)) return false;
    if (end != null) {
      final endDay = DateTime(end.year, end.month, end.day);
      if (today.isAfter(endDay)) return false;
    }
    return isEnabled;
  }

  ReminderModel copyWith({
    String? medicineName,
    String? dosage,
    String? frequency,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? notes,
    bool? isEnabled,
  }) {
    return ReminderModel(
      id: id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      notes: notes ?? this.notes,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
    );
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'] as String? ?? '',
        medicineName: json['medicine_name'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        frequency: json['frequency'] as String? ?? 'Once daily',
        times: (json['times'] as List? ?? []).whereType<String>().toList(),
        startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        endDate: json['end_date'] != null
            ? DateTime.tryParse(json['end_date'] as String)
            : null,
        notes: json['notes'] as String?,
        isEnabled: json['is_enabled'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicine_name': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'times': times,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'notes': notes,
        'is_enabled': isEnabled,
        'created_at': createdAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, isEnabled, times];
}
