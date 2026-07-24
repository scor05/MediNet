import 'package:frontend/features/user/domain/entities/patient_profile.dart';

class PatientProfileModel extends PatientProfile {
  const PatientProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.isActive,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': isActive,
    };
  }
}
