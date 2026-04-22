import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class CreateClientUsecase {
  final ClientRepository repository;

  CreateClientUsecase(this.repository);

  // Crea un nuevo cliente
  Future<Client> call({
    required String name,
    required String nit,
    int? userId,
  }) async {
    return await repository.createClient(name: name, nit: nit, userId: userId);
  }
}
