import '../../domain/entities/clinic.dart';

class ClinicModel extends Clinic {
  ClinicModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool,
    );
  }
}
