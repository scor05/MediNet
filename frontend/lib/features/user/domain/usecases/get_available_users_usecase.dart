import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/repositories/user_repository.dart';

class GetAvailableUsersUsecase {
  final UserRepository repository;

  GetAvailableUsersUsecase(this.repository);

  // Se devuelven todos los usuarios que no son superadmin
  Future<List<User>> call(String search) async {
    return await repository.getAvailableUsers(search);
  }
}
