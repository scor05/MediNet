import 'package:frontend/features/admin/domain/entities/user.dart';
import 'package:frontend/features/admin/domain/repositories/user_repository.dart';

class GetAvailableUsersForClientUsecase {
  final UserRepository repository;

  GetAvailableUsersForClientUsecase(this.repository);

  Future<List<User>> call(int clientId, String search) {
    return repository.getAvailableUsersForClient(clientId, search);
  }
}
