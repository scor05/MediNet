import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class GetAvailableUsersForClientUsecase {
  final ClientRepository repository;

  GetAvailableUsersForClientUsecase(this.repository);

  // Obtiene los usuarios disponibles para agregar a un cliente
  Future<List<ClientUser>> call(int clientId, String search) {
    return repository.getAvailableUsersForClient(clientId, search);
  }
}
