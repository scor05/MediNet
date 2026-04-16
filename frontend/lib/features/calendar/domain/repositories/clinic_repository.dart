import '../entities/clinic.dart';

abstract class ClinicRepository {
  Future<List<Clinic>> getClinics();
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  });
}
