import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

class GetPublicDoctorsUsecase {
  final PublicCalendarRepository repository;

  GetPublicDoctorsUsecase(this.repository);

  Future<List<User>> call({int? clinicId}) {
    return repository.getDoctors(clinicId: clinicId);
  }
}
