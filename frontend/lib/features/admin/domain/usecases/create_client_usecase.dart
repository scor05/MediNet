import 'package:frontend/features/admin/domain/entities/client.dart';
import 'package:frontend/features/admin/domain/repositories/client_repository.dart';

class CreateClientUsecase {
  final ClientRepository repository;

  CreateClientUsecase(this.repository);

  Future<Client> call({
    required String name,
    required String nit,
    int? userId,
  }) async {
    return await repository.createClient(name: name, nit: nit, userId: userId);
  }
}
