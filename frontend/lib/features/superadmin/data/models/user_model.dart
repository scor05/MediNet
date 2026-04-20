import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.isAccountActive,
    required super.createdAt,
    required super.updatedAt,
    required super.role,
    required super.isAdmin,
    required super.isActiveInClient,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return UserModel(
      id: user['id'] as int,
      name: user['name'] as String,
      email: user['email'] as String,
      phone: user['phone'] as String,
      isAccountActive: user['is_active'] as bool,
      createdAt: DateTime.parse(user['created_at']),
      updatedAt: DateTime.parse(user['updated_at']),
      role: _mapRole(json['role'] as int),
      isAdmin: json['is_admin'] as bool,
      isActiveInClient: json['is_active'] as bool,
    );
  }

  static String _mapRole(int role) {
    switch (role) {
      case 0:
        return 'Administrador';
      case 1:
        return 'Doctor';
      case 2:
        return 'Secretaria';
      default:
        return 'Unknown';
    }
  }
}
