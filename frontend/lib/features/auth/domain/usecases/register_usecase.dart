import '../repositories/auth_repository.dart';
import '../results/auth_result.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<AuthResult> call({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    return await repository.register(
      email: email.trim(),
      password: password,
      name: name.trim(),
      phone: phone.trim(),
    );
  }
}
