import 'package:frontend/features/user/domain/entities/user.dart';

abstract class UserRepository {
  // Devuelve todos los usuarios que no son superadmin
  Future<List<User>> getAvailableUsers(String search);
}
