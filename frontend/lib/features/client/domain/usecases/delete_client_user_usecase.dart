import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class DeleteClientUserUsecase {
  final ClientRepository repository;

  DeleteClientUserUsecase(this.repository);

  Future<void> call(int clientId, int userId) {
    return repository.deleteClientUser(clientId, userId);
  }
}
