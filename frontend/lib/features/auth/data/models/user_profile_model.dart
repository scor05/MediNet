import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.isDoctor,
    required super.isSecretary,
    required super.adminOf,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      isDoctor: json['is_doctor'] == true,
      isSecretary: json['is_secretary'] == true,
      adminOf: json['admin_of'] is List ? json['admin_of'] as List : [],
    );
  }
}
