import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';

void main() {
  testWidgets('forwards appointment taps from the general calendar', (
    tester,
  ) async {
    final appointment = Appointment(
      id: 10,
      scheduleId: 4,
      patientId: 7,
      patientName: 'Ana Perez',
      date: DateTime(2026, 8, 17),
      startTime: '08:00:00',
      status: 'accepted',
      createdAt: DateTime(2026, 8, 1),
      createdBy: 7,
      updatedAt: DateTime(2026, 8, 1),
      updatedBy: 7,
      doctorId: 3,
      doctorName: 'Dr. Ruiz',
      clinicId: 2,
      clinicName: 'Zona 15',
      appointmentDuration: 30,
    );
    Appointment? tappedAppointment;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CalendarBody(
              calendarAsync: AsyncData([appointment]),
              weekStart: DateTime(2026, 8, 17),
              onRetry: () {},
              showPatient: true,
              onAppointmentTap: (value) => tappedAppointment = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ana Perez'));

    expect(tappedAppointment, same(appointment));
  });
}
