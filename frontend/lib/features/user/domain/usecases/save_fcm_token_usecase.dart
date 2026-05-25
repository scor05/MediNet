import 'package:frontend/features/user/domain/repositories/user_repository.dart';

class SaveFcmTokenUsecase {
  final UserRepository repository;

  SaveFcmTokenUsecase(this.repository);

  Future<void> call() async {
    await repository.saveFcmToken();
  }
}
