import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/data/providers/public_calendar_data_providers.dart';
import 'package:frontend/features/calendar/domain/usecases/get_public_clinics_usecase.dart';
import 'package:frontend/features/calendar/domain/usecases/get_public_doctors_usecase.dart';
import 'package:frontend/features/calendar/domain/usecases/get_public_slots_usecase.dart';

// Provider para el usecase getPublicDoctors
final getPublicDoctorsUsecaseProvider = Provider((ref) {
  return GetPublicDoctorsUsecase(ref.read(publicCalendarRepositoryProvider));
});

// Provider para el usecase getPublicClinics
final getPublicClinicsUsecaseProvider = Provider((ref) {
  return GetPublicClinicsUsecase(ref.read(publicCalendarRepositoryProvider));
});

// Provider para el usecase getPublicSlots
final getPublicSlotsUsecaseProvider = Provider((ref) {
  return GetPublicSlotsUsecase(ref.read(publicCalendarRepositoryProvider));
});
