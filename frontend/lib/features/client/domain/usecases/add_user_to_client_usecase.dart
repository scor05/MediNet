import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class AddUserToClientUsecase {
  final ClientRepository repository;

  AddUserToClientUsecase(this.repository);

  // Agrega un usuario a un cliente
  Future<ClientUser> call(int clientId, int userId, String role, bool isAdmin) {
    return repository.addUserToClient(clientId, userId, role, isAdmin);
  }
}
