import 'package:equatable/equatable.dart';

class DonorModel extends Equatable {
  const DonorModel({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.location,
    required this.isAvailable,
    this.lastDonationDate,
    this.totalDonations = 0,
  });

  final String id;
  final String name;
  final String bloodGroup;
  final String location;
  final bool isAvailable;
  final DateTime? lastDonationDate;
  final int totalDonations;

  /// Eligibility: typical guidance is ~3 months between whole-blood donations.
  /// The backend is the source of truth for eligibility; this is a UI hint only.
  bool get isEligibleByDate {
    final last = lastDonationDate;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 90;
  }

  // NOTE: contact details are intentionally NOT part of this model.
  // Donor contact privacy will be enforced by Firestore rules / backend
  // authorization; the app communicates requests instead of exposing numbers.

  factory DonorModel.fromJson(Map<String, dynamic> json) => DonorModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        bloodGroup: json['blood_group'] as String? ?? '',
        location: json['location'] as String? ?? '',
        isAvailable: json['is_available'] as bool? ?? false,
        lastDonationDate: json['last_donation_date'] != null
            ? DateTime.tryParse(json['last_donation_date'] as String)
            : null,
        totalDonations: json['total_donations'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'blood_group': bloodGroup,
        'location': location,
        'is_available': isAvailable,
        'last_donation_date': lastDonationDate?.toIso8601String(),
        'total_donations': totalDonations,
      };

  DonorModel copyWith({bool? isAvailable, DateTime? lastDonationDate}) {
    return DonorModel(
      id: id,
      name: name,
      bloodGroup: bloodGroup,
      location: location,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      totalDonations: totalDonations,
    );
  }

  @override
  List<Object?> get props => [id, isAvailable];
}
