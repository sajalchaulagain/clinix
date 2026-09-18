import 'package:equatable/equatable.dart';

class DoctorModel extends Equatable {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospitalName,
    required this.location,
    this.rating = 0,
    this.yearsExperience = 0,
    this.consultationFee,
    this.imageUrl,
    this.isAvailableToday = false,
    this.bio,
  });

  final String id;
  final String name;
  final String specialty;
  final String hospitalName;
  final String location;
  final double rating;
  final int yearsExperience;
  final double? consultationFee;
  final String? imageUrl;
  final bool isAvailableToday;
  final String? bio;

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        specialty: json['specialty'] as String? ?? '',
        hospitalName: json['hospital_name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        yearsExperience: json['years_experience'] as int? ?? 0,
        consultationFee: (json['consultation_fee'] as num?)?.toDouble(),
        imageUrl: json['image_url'] as String?,
        isAvailableToday: json['is_available_today'] as bool? ?? false,
        bio: json['bio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'hospital_name': hospitalName,
        'location': location,
        'rating': rating,
        'years_experience': yearsExperience,
        'consultation_fee': consultationFee,
        'image_url': imageUrl,
        'is_available_today': isAvailableToday,
        'bio': bio,
      };

  @override
  List<Object?> get props => [id];
}
