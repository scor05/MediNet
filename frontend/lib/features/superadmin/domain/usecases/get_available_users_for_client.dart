import 'package:frontend/features/superadmin/domain/entities/user.dart';
import 'package:frontend/features/superadmin/domain/repositories/user_repository.dart';

class GetAvailableUsersForClient {
  final UserRepository repository;

  GetAvailableUsersForClient(this.repository);

  Future<List<User>> call(int clientId, String search) {
    return repository.getAvailableUsersForClient(clientId, search);
  }
}
