import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class EditClientUsecase {
  final ClientRepository repository;

  EditClientUsecase(this.repository);

  // Edita la información de un cliente
  Future<Client> call({
    required int clientId,
    required String name,
    required String nit,
  }) {
    return repository.editClient(clientId, name: name, nit: nit);
  }
}
