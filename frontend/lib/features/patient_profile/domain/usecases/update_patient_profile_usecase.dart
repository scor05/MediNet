import 'package:frontend/features/patient_profile/domain/entities/patient_profile.dart';
import 'package:frontend/features/patient_profile/domain/repositories/patient_profile_repository.dart';

class UpdatePatientProfileUsecase {
  final PatientProfileRepository repository;

  UpdatePatientProfileUsecase(this.repository);

  Future<PatientProfile> call({String? name, String? phone}) {
    return repository.updatePatientProfile(name: name, phone: phone);
  }
}
