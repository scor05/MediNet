import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

class CreateClinicUsecase {
  final ClinicRepository repository;

  CreateClinicUsecase(this.repository);

  // Crea una clínica
  Future<Clinic> call(
    String name,
    String address,
    String phone,
    String email,
    int clientId,
  ) {
    return repository.createClinic(
      name: name,
      address: address,
      phone: phone,
      email: email,
      clientId: clientId,
    );
  }
}
