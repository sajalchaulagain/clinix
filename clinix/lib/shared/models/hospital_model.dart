import 'package:equatable/equatable.dart';

class HospitalModel extends Equatable {
  const HospitalModel({
    required this.id,
    required this.name,
    required this.location,
    required this.bloodUnitsByGroup,
    required this.lastUpdated,
    this.phone,
    this.isOpen24Hours = false,
  });

  final String id;
  final String name;
  final String location;
  final String? phone;
  final bool isOpen24Hours;

  /// Units available per blood group, e.g. {'A+': 12, 'O-': 2}.
  final Map<String, int> bloodUnitsByGroup;
  final DateTime lastUpdated;

  int get totalUnits =>
      bloodUnitsByGroup.values.fold(0, (sum, units) => sum + units);

  factory HospitalModel.fromJson(Map<String, dynamic> json) => HospitalModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        phone: json['phone'] as String?,
        isOpen24Hours: json['is_open_24_hours'] as bool? ?? false,
        bloodUnitsByGroup:
            (json['blood_units_by_group'] as Map<String, dynamic>? ?? {})
                .map((key, value) => MapEntry(key, (value as num).toInt())),
        lastUpdated:
            DateTime.tryParse(json['last_updated'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'phone': phone,
        'is_open_24_hours': isOpen24Hours,
        'blood_units_by_group': bloodUnitsByGroup,
        'last_updated': lastUpdated.toIso8601String(),
      };

  @override
  List<Object?> get props => [id];
}
