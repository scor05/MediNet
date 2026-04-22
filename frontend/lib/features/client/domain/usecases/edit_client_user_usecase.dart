import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class EditClientUserUsecase {
  final ClientRepository repository;

  EditClientUserUsecase(this.repository);

  // Edita el rol y estado de un usuario de un cliente
  Future<ClientUser> call({
    required int clientId,
    required int userId,
    required String role,
    required bool isAdmin,
    required bool isActive,
  }) {
    return repository.editClientUser(
      clientId,
      userId,
      _mapRole(role),
      isAdmin,
      isActive,
    );
  }
}

/*
--------------------------------- HELPERS --------------------------------
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
