import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

class GetClinicsUsecase {
  final ClinicRepository repository;

  GetClinicsUsecase(this.repository);

  // Obtiene las clínicas de un cliente
  Future<List<Clinic>> call(int? clientId) {
    return repository.getClinics(clientId);
  }
}
