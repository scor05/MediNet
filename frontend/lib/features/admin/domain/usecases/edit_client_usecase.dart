import '../entities/client.dart';
import '../repositories/client_repository.dart';

class EditClientUsecase {
  final ClientRepository repository;

  EditClientUsecase(this.repository);

  Future<Client> call({
    required int clientId,
    required String name,
    required String nit,
  }) {
    return repository.editClient(clientId, name: name, nit: nit);
  }
}
