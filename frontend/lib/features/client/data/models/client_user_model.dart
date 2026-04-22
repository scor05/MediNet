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
      role: json['role'],
      isAdmin: json['is_admin'],
      isActiveInClient: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'is_admin': isAdmin, 'is_active': isActiveInClient};
  }
}
