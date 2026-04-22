import 'package:frontend/features/admin/domain/entities/clinic.dart';

abstract class ClinicRepository {
  Future<List<Clinic>> getClinics(int clientId);
}
