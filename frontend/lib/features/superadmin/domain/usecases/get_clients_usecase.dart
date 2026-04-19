import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientsUsecase {
  final ClientRepository repository;

  GetClientsUsecase(this.repository);

  Future<List<Client>> call() {
    return repository.getClients();
  }
}
