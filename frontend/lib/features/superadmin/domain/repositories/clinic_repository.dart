import 'package:frontend/features/superadmin/domain/entities/clinic.dart';

abstract class ClinicRepository {
  Future<List<Clinic>> getClinics(int clientId);
}
