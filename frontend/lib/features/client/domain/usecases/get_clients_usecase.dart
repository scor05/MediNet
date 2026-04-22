import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class GetClientsUsecase {
  final ClientRepository repository;

  GetClientsUsecase(this.repository);

  // Obtiene todos los clientes
  Future<List<Client>> call() {
    return repository.getClients();
  }
}
