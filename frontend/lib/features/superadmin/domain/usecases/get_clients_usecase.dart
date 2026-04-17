import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientsUseCase {
  final ClientRepository repository;

  GetClientsUseCase(this.repository);

  Future<List<Client>> call() {
    return repository.getClients();
  }
}
