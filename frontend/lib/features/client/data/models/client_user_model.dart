import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/user/data/models/user_model.dart';

class ClientUserModel extends ClientUser {
  const ClientUserModel({
    required super.user,
    required super.role,
    required super.isAdmin,
    required super.isActiveInClient,
  });

  factory ClientUserModel.fromJson(Map<String, dynamic> json) {
    return ClientUserModel(
      user: UserModel.fromJson(json['user']),
      role: _roleToString(json['role']),
      isAdmin: json['is_admin'],
      isActiveInClient: json['is_active'],
    );
  }

  factory ClientUserModel.fromSearch(Map<String, dynamic> json) {
    return ClientUserModel(
      user: UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: '',
        isAccountActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      role: '',
      isAdmin: false,
      isActiveInClient: false,
    );
  }

  factory ClientUserModel.fromSummary(Map<String, dynamic> json) {
    return ClientUserModel(
      user: UserModel(
        id: json['id_user'] as int,
        name: '',
        email: '',
        phone: '',
        isAccountActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      role: _roleToString(json['role'] as int),
      isAdmin: json['is_admin'] as bool,
      isActiveInClient: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'is_admin': isAdmin, 'is_active': isActiveInClient};
  }
}

/*
-------------------------------- Helpers ------------------------------------
*/

String _roleToString(int role) {
  switch (role) {
    case 0:
      return 'Administrador';
    case 1:
      return 'Doctor';
    case 2:
      return 'Paciente';
    default:
      throw ApiException('Rol desconocido: $role');
  }
}
