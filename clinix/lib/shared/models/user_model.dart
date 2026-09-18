import 'package:equatable/equatable.dart';

/// Role assigned by the backend/Firebase custom claims in production.
/// The mock repository assigns this for demo purposes only — real
/// authorization is always enforced server-side.
enum UserRole { patient, admin }

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.dateOfBirth,
    this.bloodGroup,
    this.emergencyContact,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? emergencyContact;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;

  static UserRole _roleFromJson(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.patient;

  static String _roleToJson(UserRole role) => role.name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: _roleFromJson(json['role'] as String?),
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      bloodGroup: json['blood_group'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      photoUrl: json['photo_url'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': _roleToJson(role),
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'blood_group': bloodGroup,
        'emergency_contact': emergencyContact,
        'photo_url': photoUrl,
        'email_verified': emailVerified,
        'created_at': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? emergencyContact,
    String? photoUrl,
    bool? emailVerified,
    UserRole? role,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, role];
}
