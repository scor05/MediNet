import '../../domain/entities/user_profile.dart';
import 'admin_of_model.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.isActive,
    required super.isDoctor,
    required super.isSecretary,
    required super.isSuperadmin,
    required super.adminOf,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      isActive: json['is_active'] == true,
      isDoctor: json['is_doctor'] == true,
      isSecretary: json['is_secretary'] == true,
      isSuperadmin: json['superadmin'] == true,

      adminOf: (json['admin_of'] as List<dynamic>? ?? [])
          .map((e) => AdminOfModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
