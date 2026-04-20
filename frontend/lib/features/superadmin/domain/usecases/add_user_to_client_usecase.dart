import 'package:frontend/features/superadmin/domain/repositories/user_repository.dart';

class AddUserToClientUsecase {
  final UserRepository repository;

  AddUserToClientUsecase(this.repository);

  Future<void> call(int clientId, int userId, String role, bool isAdmin) {
    return repository.addUserToClient(
      clientId,
      userId,
      _mapRole(role),
      isAdmin,
    );
  }
}

/*
HELPERS
*/

int _mapRole(String role) {
  switch (role.toLowerCase()) {
    case 'administrador':
      return 1;
    case 'doctor':
      return 2;
    case 'secretaria':
      return 3;
    default:
      throw ArgumentError('Rol desconocido: $role');
  }
}
