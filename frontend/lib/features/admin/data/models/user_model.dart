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

  factory UserModel.fromClientUserJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return UserModel(
      id: user['id'] as int,
      name: user['name'] as String,
      email: user['email'] as String,
      phone: (user['phone'] ?? '') as String,
      isAccountActive: user['is_active'] as bool,
      createdAt: DateTime.parse(user['created_at'] as String),
      updatedAt: DateTime.parse(user['updated_at'] as String),
      role: _mapRole(json['role'] as int),
      isAdmin: json['is_admin'] as bool,
      isActiveInClient: json['is_active'] as bool,
    );
  }

  factory UserModel.fromAvailableUserJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] ?? '') as String,
      isAccountActive: (json['is_active'] ?? true) as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      role: '',
      isAdmin: false,
      isActiveInClient: false,
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
