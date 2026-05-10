import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';

class GetPublicClinicsUsecase {
  final PublicCalendarRepository repository;

  GetPublicClinicsUsecase(this.repository);

  Future<List<Clinic>> call({int? doctorId}) {
    return repository.getClinics(doctorId: doctorId);
  }
}
