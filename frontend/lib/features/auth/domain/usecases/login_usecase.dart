import '../repositories/auth_repository.dart';
import '../results/auth_result.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email.trim(), password: password);
  }
}
