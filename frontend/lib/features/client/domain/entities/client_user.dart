import 'package:frontend/features/user/domain/entities/user.dart';

class ClientUser {
  final User user;
  final String role;
  final bool isAdmin;
  final bool isActiveInClient;

  const ClientUser({
    required this.user,
    required this.role,
    required this.isAdmin,
    required this.isActiveInClient,
  });

  ClientUser copyWith({
    User? user,
    String? role,
    bool? isAdmin,
    bool? isActiveInClient,
  }) {
    return ClientUser(
      user: user ?? this.user,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
      isActiveInClient: isActiveInClient ?? this.isActiveInClient,
    );
  }
}
