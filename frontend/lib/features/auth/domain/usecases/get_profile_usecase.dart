import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class GetProfileUsecase {
  final AuthRepository repository;

  GetProfileUsecase(this.repository);

  Future<UserProfile> call() async {
    return repository.getProfile();
  }
}
