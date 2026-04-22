import '../entities/clinic.dart';
import '../repositories/clinic_repository.dart';

class GetClientClinicsUsecase {
  final ClinicRepository repository;

  GetClientClinicsUsecase(this.repository);

  Future<List<Clinic>> call(int clientId) {
    return repository.getClinics(clientId);
  }
}
