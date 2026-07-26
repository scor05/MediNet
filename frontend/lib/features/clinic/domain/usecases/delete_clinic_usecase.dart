import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

class DeleteClinicUsecase {
  final ClinicRepository repository;

  DeleteClinicUsecase(this.repository);

  Future<void> call(int clinicId) {
    return repository.deleteClinic(clinicId);
  }
}
