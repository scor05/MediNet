import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/domain/providers/public_calendar_domain_providers.dart';
import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';
import 'package:frontend/features/calendar/domain/usecases/get_public_slots_usecase.dart';
import 'package:frontend/features/calendar/presentation/providers/create_appointment_form_provider.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:frontend/features/schedule/domain/usecases/get_schedules_by_doctor_id_usecase.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

void main() {
  test(
    'keeps only unoccupied slots for the selected schedule and date',
    () async {
      final container = ProviderContainer(
        overrides: [
          getSchedulesByDoctorIdUsecaseProvider.overrideWithValue(
            GetSchedulesByDoctorIdUsecase(_ScheduleRepository()),
          ),
          getPublicSlotsUsecaseProvider.overrideWithValue(
            GetPublicSlotsUsecase(_PublicCalendarRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final provider = createAppointmentFormProvider(DateTime(2026, 10, 5));
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      final notifier = container.read(provider.notifier);

      await notifier.selectDoctor(
        const DoctorSearchResult(id: 7, name: 'Dr. Ruiz', specialty: ''),
      );
      notifier.selectClinic(
        const ClinicSearchResult(
          id: 2,
          name: 'Clínica Central',
          address: 'Zona 15',
        ),
      );

      expect(container.read(provider).loadingTimeSlots, isTrue);
      for (var attempt = 0; attempt < 20; attempt++) {
        if (!container.read(provider).loadingTimeSlots) break;
        await Future<void>.delayed(Duration.zero);
      }

      final state = container.read(provider);
      expect(state.loadingTimeSlots, isFalse);
      expect(state.timeSlots, ['08:00', '09:00']);
      expect(state.selectedTime, '08:00');
      expect(state.timeSlots, isNot(contains('08:30')));
    },
  );
}

class _ScheduleRepository implements ScheduleRepository {
  @override
  Future<List<Schedule>> getSchedulesByDoctorId(int doctorId) async => const [
    Schedule(
      id: 4,
      dayOfWeek: 0,
      startTime: '08:00:00',
      endTime: '10:00:00',
      duration: 30,
      doctorId: 7,
      doctorName: 'Dr. Ruiz',
      clinicId: 2,
      clinicName: 'Clínica Central',
    ),
  ];

  @override
  Future<Schedule> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteSchedule(int id) => throw UnimplementedError();

  @override
  Future<List<Schedule>> getDoctorSchedules() async => const [];

  @override
  Future<List<Schedule>> getSecretarySchedules() async => const [];

  @override
  Future<Schedule> updateSchedule({
    required int id,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) => throw UnimplementedError();
}

class _PublicCalendarRepository implements PublicCalendarRepository {
  @override
  Future<List<PublicSlot>> getSlots({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  }) async => const [
    PublicSlot(
      scheduleId: 4,
      startTime: '08:00',
      endTime: '08:30',
      isOccupied: false,
      doctorId: 7,
      doctorName: 'Dr. Ruiz',
      clinicId: 2,
      clinicName: 'Clínica Central',
    ),
    PublicSlot(
      scheduleId: 4,
      startTime: '08:30',
      endTime: '09:00',
      isOccupied: true,
      doctorId: 7,
      doctorName: 'Dr. Ruiz',
      clinicId: 2,
      clinicName: 'Clínica Central',
    ),
    PublicSlot(
      scheduleId: 4,
      startTime: '09:00',
      endTime: '09:30',
      isOccupied: false,
      doctorId: 7,
      doctorName: 'Dr. Ruiz',
      clinicId: 2,
      clinicName: 'Clínica Central',
    ),
  ];

  @override
  Future<void> createAppointmentRequest({
    required int scheduleId,
    required int patientId,
    required String patientName,
    required DateTime date,
    required String startTime,
  }) => throw UnimplementedError();

  @override
  Future<List<Clinic>> getClinics({int? doctorId}) async => const [];

  @override
  Future<List<User>> getDoctors({int? clinicId}) async => const [];
}
