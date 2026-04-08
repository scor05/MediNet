import '../entities/clinic.dart';
import '../repositories/clinic_repository.dart';

class GetClinics {
  final ClinicRepository repository;

  GetClinics(this.repository);

  Future<List<Clinic>> call() async {
    return await repository.getClinics();
  }
}
