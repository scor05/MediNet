import 'package:frontend/features/auth/domain/results/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
}