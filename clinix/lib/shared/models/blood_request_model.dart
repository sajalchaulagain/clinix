import 'package:equatable/equatable.dart';

enum BloodRequestUrgency { normal, urgent, critical }

enum BloodRequestStatus { pending, approved, fulfilled, cancelled }

class BloodRequestModel extends Equatable {
  const BloodRequestModel({
    required this.id,
    required this.requesterName,
    required this.bloodGroup,
    required this.units,
    required this.hospitalName,
    required this.location,
    required this.status,
    required this.createdAt,
    this.urgency = BloodRequestUrgency.normal,
    this.reason,
    this.patientName,
  });

  final String id;
  final String requesterName;
  final String bloodGroup;
  final int units;
  final String hospitalName;
  final String location;
  final BloodRequestStatus status;
  final DateTime createdAt;
  final BloodRequestUrgency urgency;
  final String? reason;
  final String? patientName;

  static T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) =>
      BloodRequestModel(
        id: json['id'] as String? ?? '',
        requesterName: json['requester_name'] as String? ?? '',
        bloodGroup: json['blood_group'] as String? ?? '',
        units: json['units'] as int? ?? 1,
        hospitalName: json['hospital_name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        status: _enumFromName(
          BloodRequestStatus.values,
          json['status'] as String?,
          BloodRequestStatus.pending,
        ),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        urgency: _enumFromName(
          BloodRequestUrgency.values,
          json['urgency'] as String?,
          BloodRequestUrgency.normal,
        ),
        reason: json['reason'] as String?,
        patientName: json['patient_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'requester_name': requesterName,
        'blood_group': bloodGroup,
        'units': units,
        'hospital_name': hospitalName,
        'location': location,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'urgency': urgency.name,
        'reason': reason,
        'patient_name': patientName,
      };

  @override
  List<Object?> get props => [id, status];
}
