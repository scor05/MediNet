import 'package:frontend/features/superadmin/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers(int clientId);
}
