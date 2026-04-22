import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class GetClientUsersUsecase {
  final ClientRepository repository;

  GetClientUsersUsecase(this.repository);

  // Obtiene los usuarios de un cliente
  Future<List<ClientUser>> call(int clientId) {
    return repository.getClientUsers(clientId);
  }
}
