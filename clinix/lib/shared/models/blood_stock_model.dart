import 'package:equatable/equatable.dart';

class BloodStockModel extends Equatable {
  const BloodStockModel({
    required this.id,
    required this.bloodGroup,
    required this.hospitalName,
    required this.location,
    required this.unitsAvailable,
    required this.lastUpdated,
    this.hospitalId,
  });

  final String id;
  final String bloodGroup;
  final String hospitalName;
  final String location;
  final int unitsAvailable;
  final DateTime lastUpdated;
  final String? hospitalId;

  bool get isAvailable => unitsAvailable > 0;

  String get availabilityLabel {
    if (unitsAvailable <= 0) return 'Out of stock';
    if (unitsAvailable < 5) return 'Low stock';
    return 'Available';
  }

  factory BloodStockModel.fromJson(Map<String, dynamic> json) =>
      BloodStockModel(
        id: json['id'] as String? ?? '',
        bloodGroup: json['blood_group'] as String? ?? '',
        hospitalName: json['hospital_name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        unitsAvailable: json['units_available'] as int? ?? 0,
        lastUpdated:
            DateTime.tryParse(json['last_updated'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
        hospitalId: json['hospital_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'blood_group': bloodGroup,
        'hospital_name': hospitalName,
        'location': location,
        'units_available': unitsAvailable,
        'last_updated': lastUpdated.toIso8601String(),
        'hospital_id': hospitalId,
      };

  BloodStockModel copyWith({int? unitsAvailable, DateTime? lastUpdated}) {
    return BloodStockModel(
      id: id,
      bloodGroup: bloodGroup,
      hospitalName: hospitalName,
      location: location,
      unitsAvailable: unitsAvailable ?? this.unitsAvailable,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hospitalId: hospitalId,
    );
  }

  @override
  List<Object?> get props => [id, bloodGroup, unitsAvailable];
}
