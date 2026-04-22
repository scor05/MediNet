import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/schedule/data/providers/schedule_data_providers.dart';
import 'package:frontend/features/schedule/domain/usecases/create_schedule_usecase.dart';
import 'package:frontend/features/schedule/domain/usecases/get_doctor_schedules_usecase.dart';

// Provider para el usecase createSchedule
final createScheduleUsecaseProvider = Provider((ref) {
  return CreateScheduleUsecase(ref.read(scheduleRepositoryProvider));
});

// Provider para el usecase getDoctorSchedules
final getDoctorSchedulesUsecaseProvider = Provider((ref) {
  return GetDoctorSchedulesUsecase(ref.read(scheduleRepositoryProvider));
});
