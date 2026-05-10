import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';

class GetPublicSlotsUsecase {
  final PublicCalendarRepository repository;

  GetPublicSlotsUsecase(this.repository);

  Future<List<PublicSlot>> call({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  }) {
    return repository.getSlots(
      doctorId: doctorId,
      clinicId: clinicId,
      date: date,
    );
  }
}
