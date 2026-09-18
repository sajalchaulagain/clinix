import 'package:equatable/equatable.dart';

class MedicineModel extends Equatable {
  const MedicineModel({
    required this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    this.category,
    this.description,
  });

  final String id;
  final String name;
  final String? genericName;
  final String? manufacturer;
  final String? category;
  final String? description;

  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        genericName: json['generic_name'] as String?,
        manufacturer: json['manufacturer'] as String?,
        category: json['category'] as String?,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'generic_name': genericName,
        'manufacturer': manufacturer,
        'category': category,
        'description': description,
      };

  @override
  List<Object?> get props => [id];
}
