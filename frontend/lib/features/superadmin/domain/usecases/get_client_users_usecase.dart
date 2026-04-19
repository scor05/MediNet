import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetClientUsersUsecase {
  final UserRepository repository;

  GetClientUsersUsecase(this.repository);

  Future<List<User>> call(int clientId) {
    return repository.getUsers(clientId);
  }
}
