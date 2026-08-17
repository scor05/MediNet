import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/repositories/user_repository.dart';

class SearchPatientsUsecase {
  final UserRepository repository;

  SearchPatientsUsecase(this.repository);

  Future<List<User>> call(String search) {
    return repository.searchPatients(search);
  }
}
