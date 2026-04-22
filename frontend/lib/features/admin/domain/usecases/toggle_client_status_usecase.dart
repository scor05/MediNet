import '../entities/client.dart';
import '../repositories/client_repository.dart';

class ToggleClientStatusUseCase {
  final ClientRepository repository;

  ToggleClientStatusUseCase(this.repository);

  Future<Client> call({required int clientId, required bool isActive}) {
    return repository.toggleClientStatus(clientId, isActive);
  }
}
