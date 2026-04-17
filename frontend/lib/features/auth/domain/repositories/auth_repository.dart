import 'package:frontend/features/auth/domain/results/auth_result.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<UserProfile> getProfile();
}
