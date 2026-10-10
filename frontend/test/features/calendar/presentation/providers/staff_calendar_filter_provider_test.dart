import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/staff_calendar_filter_provider.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

void main() {
  group('time range overlap', () {
    test('does not filter when both fields are empty', () {
      const filters = StaffCalendarFilterState();

      expect(
        filters.overlapsTimeRange(itemStartMinute: 480, itemEndMinute: 540),
        isTrue,
      );
    });

    test('start-only filter retains items that cross its lower boundary', () {
      const filters = StaffCalendarFilterState(startTime: '09:00');

      expect(
        filters.overlapsTimeRange(itemStartMinute: 510, itemEndMinute: 570),
        isTrue,
      );
      expect(
        filters.overlapsTimeRange(itemStartMinute: 480, itemEndMinute: 540),
        isFalse,
      );
    });

    test('end-only filter retains items that cross its upper boundary', () {
      const filters = StaffCalendarFilterState(endTime: '10:00');

      expect(
        filters.overlapsTimeRange(itemStartMinute: 570, itemEndMinute: 630),
        isTrue,
      );
      expect(
        filters.overlapsTimeRange(itemStartMinute: 600, itemEndMinute: 660),
        isFalse,
      );
    });

    test('bounded filter uses interval intersection', () {
      const filters = StaffCalendarFilterState(
        startTime: '09:00',
        endTime: '10:00',
      );

      expect(
        filters.overlapsTimeRange(itemStartMinute: 510, itemEndMinute: 630),
        isTrue,
      );
      expect(
        filters.overlapsTimeRange(itemStartMinute: 480, itemEndMinute: 540),
        isFalse,
      );
      expect(
        filters.overlapsTimeRange(itemStartMinute: 600, itemEndMinute: 630),
        isFalse,
      );
    });
  });

  test('applies item type, patient, doctor, and clinic filters', () {
    final appointment = _appointment();
    final blockade = _appointment().copyWith(
      id: 2,
      patientId: 0,
      type: 'blockade',
    );
    const filters = StaffCalendarFilterState(
      patientId: 11,
      filterDoctor: true,
      doctorId: 7,
      filterClinic: true,
      clinicId: 2,
      showBlockades: false,
    );

    expect(
      appointmentMatchesStaffFilters(
        appointment,
        filters,
        filterByDoctor: true,
      ),
      isTrue,
    );
    expect(
      appointmentMatchesStaffFilters(blockade, filters, filterByDoctor: true),
      isFalse,
    );
    expect(
      scheduleMatchesStaffFilters(_schedule(), filters, filterByDoctor: true),
      isTrue,
    );
  });

  test('patient filter does not hide schedules or blockades', () {
    final blockade = _appointment().copyWith(
      id: 2,
      patientId: 0,
      type: 'blockade',
    );
    const filters = StaffCalendarFilterState(patientId: 999);

    expect(
      appointmentMatchesStaffFilters(blockade, filters, filterByDoctor: false),
      isTrue,
    );
    expect(
      scheduleMatchesStaffFilters(_schedule(), filters, filterByDoctor: false),
      isTrue,
    );
  });
}

Appointment _appointment() => Appointment(
  id: 1,
  scheduleId: 4,
  patientId: 11,
  patientName: 'Ana Pérez',
  date: DateTime(2026, 10, 12),
  startTime: '09:00:00',
  status: 'accepted',
  createdAt: DateTime(2026, 10, 1),
  createdBy: 1,
  updatedAt: DateTime(2026, 10, 1),
  updatedBy: 1,
  doctorId: 7,
  doctorName: 'Dr. Ruiz',
  clinicId: 2,
  clinicName: 'Clínica Central',
  appointmentDuration: 30,
);

Schedule _schedule() => const Schedule(
  id: 4,
  dayOfWeek: 0,
  startTime: '08:00:00',
  endTime: '12:00:00',
  duration: 30,
  doctorId: 7,
  doctorName: 'Dr. Ruiz',
  clinicId: 2,
  clinicName: 'Clínica Central',
);
