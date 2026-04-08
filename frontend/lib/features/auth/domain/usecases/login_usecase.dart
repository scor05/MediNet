import '../repositories/auth_repository.dart';
import '../results/auth_result.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return AuthResult.error('Correo y contraseña son obligatorios.');
    }

    return await repository.login(
      email: email.trim(),
      password: password,
    );
  }
}