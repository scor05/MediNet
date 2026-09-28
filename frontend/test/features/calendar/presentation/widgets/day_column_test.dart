import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/day_column.dart';
import 'package:frontend/theme/calendar_theme.dart';

void main() {
  testWidgets(
    'doctor appointments share horizontal space while blockades stay full width',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final first = _appointment(id: 1, patientName: 'Ana');
      final second = _appointment(id: 2, patientName: 'Luis');
      final blockade = _appointment(
        id: 3,
        patientName: '',
        type: 'blockade',
        appointmentDuration: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 210,
                height: 960,
                child: DayColumn(
                  dayIndex: 0,
                  appointments: [first, second, blockade],
                  schedules: const [],
                  showDoctor: false,
                  showPatient: true,
                  splitOverlappingAppointments: true,
                  startHour: 6,
                  endHour: 18,
                  hourHeight: 80,
                ),
              ),
            ),
          ),
        ),
      );

      final day = tester.getRect(
        find.byKey(const ValueKey('calendar-day-column-0')),
      );
      final firstRect = tester.getRect(
        find.byKey(const ValueKey('calendar-appointment-1')),
      );
      final secondRect = tester.getRect(
        find.byKey(const ValueKey('calendar-appointment-2')),
      );
      final blockadeRect = tester.getRect(
        find.byKey(const ValueKey('calendar-blockade-3')),
      );
      final leftAppointment = firstRect.left < secondRect.left
          ? firstRect
          : secondRect;
      final rightAppointment = firstRect.left < secondRect.left
          ? secondRect
          : firstRect;

      expect(
        leftAppointment.left - day.left,
        CalendarSizes.calendarItemDayEdgeInset,
      );
      expect(rightAppointment.left - leftAppointment.right, 2);
      expect(
        day.right - rightAppointment.right,
        CalendarSizes.calendarItemDayEdgeInset,
      );
      expect(
        blockadeRect.left - day.left,
        CalendarSizes.calendarItemDayEdgeInset,
      );
      expect(
        day.right - blockadeRect.right,
        closeTo(
          CalendarSizes.calendarItemDayEdgeInset,
          CalendarSizes.dividerWidth,
        ),
      );
      expect(firstRect.width, lessThan(blockadeRect.width));
      expect(secondRect.width, lessThan(blockadeRect.width));
    },
  );
}

Appointment _appointment({
  required int id,
  required String patientName,
  String status = 'accepted',
  String? type,
  int appointmentDuration = 30,
}) {
  return Appointment(
    id: id,
    scheduleId: 4,
    patientId: 7,
    patientName: patientName,
    date: DateTime(2026, 9, 21),
    startTime: '08:00:00',
    status: status,
    createdAt: DateTime(2026, 9, 1),
    createdBy: 7,
    updatedAt: DateTime(2026, 9, 1),
    updatedBy: 7,
    doctorId: 3,
    doctorName: 'Dr. Ruiz',
    clinicId: 2,
    clinicName: 'Clínica Central',
    appointmentDuration: appointmentDuration,
    type: type,
  );
}
