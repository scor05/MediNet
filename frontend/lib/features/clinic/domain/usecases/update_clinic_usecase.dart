import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

class UpdateClinicUsecase {
  final ClinicRepository repository;

  UpdateClinicUsecase(this.repository);

  Future<Clinic> call({
    required int clinicId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) {
    return repository.updateClinic(
      clinicId: clinicId,
      name: name,
      address: address,
      phone: phone,
      email: email,
    );
  }
}
