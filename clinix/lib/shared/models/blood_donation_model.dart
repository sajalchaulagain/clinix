import 'package:equatable/equatable.dart';

enum DonationRequestStatus { pending, confirmed, completed, cancelled }

class BloodDonationModel extends Equatable {
  const BloodDonationModel({
    required this.id,
    required this.userId,
    required this.donorName,
    required this.phone,
    required this.bloodGroup,
    required this.units,
    required this.hospitalName,
    required this.location,
    required this.status,
    required this.createdAt,
    this.preferredDate,
    this.notes,
  });

  final String id;
  final String userId;
  final String donorName;
  final String phone;
  final String bloodGroup;
  final int units;
  final String hospitalName;
  final String location;
  final DonationRequestStatus status;
  final DateTime createdAt;
  final DateTime? preferredDate;
  final String? notes;

  static T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  factory BloodDonationModel.fromJson(Map<String, dynamic> json) =>
      BloodDonationModel(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        donorName: json['donor_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        bloodGroup: json['blood_group'] as String? ?? '',
        units: json['units'] as int? ?? 1,
        hospitalName: json['hospital_name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        status: _enumFromName(
          DonationRequestStatus.values,
          json['status'] as String?,
          DonationRequestStatus.pending,
        ),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        preferredDate: json['preferred_date'] != null
            ? DateTime.tryParse(json['preferred_date'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'donor_name': donorName,
        'phone': phone,
        'blood_group': bloodGroup,
        'units': units,
        'hospital_name': hospitalName,
        'location': location,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        if (preferredDate != null)
          'preferred_date': preferredDate!.toIso8601String().substring(0, 10),
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [id, status];
}
