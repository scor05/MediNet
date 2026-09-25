import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:frontend/features/schedule/domain/usecases/create_schedule_usecase.dart';

void main() {
  test('forwards the secretary-selected doctor id', () async {
    final repository = _RecordingScheduleRepository();
    final usecase = CreateScheduleUsecase(repository);

    await usecase.call(
      doctorId: 42,
      clinicId: 7,
      dayOfWeek: 2,
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 0),
      duration: 30,
    );

    expect(repository.receivedDoctorId, 42);
  });

  test('keeps the doctor id absent for the doctor flow', () async {
    final repository = _RecordingScheduleRepository();
    final usecase = CreateScheduleUsecase(repository);

    await usecase.call(
      clinicId: 7,
      dayOfWeek: 2,
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 0),
      duration: 30,
    );

    expect(repository.receivedDoctorId, isNull);
  });
}

class _RecordingScheduleRepository implements ScheduleRepository {
  int? receivedDoctorId;

  @override
  Future<Schedule> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    receivedDoctorId = doctorId;
    return Schedule(
      id: 1,
      dayOfWeek: dayOfWeek,
      startTime: '${startTime.hour}:00',
      endTime: '${endTime.hour}:00',
      duration: duration,
      doctorId: doctorId ?? 0,
      clinicId: clinicId,
      clinicName: 'Clínica',
    );
  }

  @override
  Future<List<Schedule>> getDoctorSchedules() async => const [];

  @override
  Future<List<Schedule>> getSchedulesByDoctorId(int doctorId) async => const [];

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

  @override
  Future<void> deleteSchedule(int id) => throw UnimplementedError();
}
