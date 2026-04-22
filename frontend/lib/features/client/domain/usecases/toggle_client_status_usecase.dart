import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class ToggleClientStatusUseCase {
  final ClientRepository repository;

  ToggleClientStatusUseCase(this.repository);

  // Cambia el estado de un cliente
  Future<Client> call({required int clientId, required bool isActive}) {
    return repository.toggleClientStatus(clientId, isActive);
  }
}
