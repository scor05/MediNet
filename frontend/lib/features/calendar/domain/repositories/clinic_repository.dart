import '../entities/clinic.dart';

abstract class ClinicRepository {
  Future<List<Clinic>> getClinics();
  Future<void> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  });
}
