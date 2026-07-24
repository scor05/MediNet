import 'package:frontend/features/user/domain/entities/patient_profile.dart';
import 'package:frontend/features/user/domain/repositories/user_repository.dart';

class GetPatientProfileUsecase {
  final UserRepository repository;

  GetPatientProfileUsecase(this.repository);

  Future<PatientProfile> call() async {
    return repository.getPatientProfile();
  }
}
