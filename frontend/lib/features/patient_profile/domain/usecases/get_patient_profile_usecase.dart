import 'package:frontend/features/patient_profile/domain/entities/patient_profile.dart';
import 'package:frontend/features/patient_profile/domain/repositories/patient_profile_repository.dart';

class GetPatientProfileUsecase {
  final PatientProfileRepository repository;

  GetPatientProfileUsecase(this.repository);

  Future<PatientProfile> call() {
    return repository.getPatientProfile();
  }
}
