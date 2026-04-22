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
    return repository.editClientUser(clientId, userId, role, isAdmin, isActive);
  }
}
