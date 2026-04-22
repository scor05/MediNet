import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/user.dart';
import 'package:frontend/features/admin/domain/repositories/user_repository.dart';

class GetAvailableUsersUsecase {
  final UserRepository repository;

  GetAvailableUsersUsecase(this.repository);

  Future<List<User>> call(String search) async {
    try {
      return await repository.getAvailableUsers(search);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }
}
