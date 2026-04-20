import 'package:frontend/features/superadmin/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getClientUsers(int clientId);
  Future<List<User>> getAvailableUsersForClient(int clientId, String search);
  Future<void> addUserToClient(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
  );
  Future<List<User>> getAvailableUsers(String search);
}
