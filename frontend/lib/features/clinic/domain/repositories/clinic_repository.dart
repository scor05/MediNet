import 'package:frontend/features/clinic/domain/entities/clinic.dart';

abstract class ClinicRepository {
  // Obtiene las clínicas de un cliente
  Future<List<Clinic>> getClinics(int? clientId);

  // Crea una nueva clínica
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
    required int clientId,
  });
}
