import 'package:frontend/features/admin/domain/repositories/user_repository.dart';

class UpdateClientUserAdminUsecase {
  final UserRepository repository;

  UpdateClientUserAdminUsecase(this.repository);

  Future<void> call({
    required int clientId,
    required int userId,
    required String role,
    required bool isAdmin,
    required bool isActive,
  }) {
    return repository.updateClientUserAdminPrivileges(
      clientId,
      userId,
      _mapRole(role),
      isAdmin,
      isActive,
    );
  }
}

/*
HELPERS
*/

int _mapRole(String role) {
  switch (role.toLowerCase()) {
    case 'administrador':
      return 0;
    case 'doctor':
      return 1;
    case 'secretaria':
      return 2;
    default:
      throw ArgumentError('Rol desconocido: $role');
  }
}
