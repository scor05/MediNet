import 'package:frontend/features/superadmin/domain/repositories/user_repository.dart';

class UpdateClientUserAdminUsecase {
  final UserRepository repository;

  UpdateClientUserAdminUsecase(this.repository);

  Future<void> call({
    required int clientId,
    required int userId,
    required int role,
    required bool isAdmin,
    required bool isActive,
  }) {
    return repository.updateClientUserAdminPrivileges(
      clientId,
      userId,
      role,
      isAdmin,
      isActive,
    );
  }
}
