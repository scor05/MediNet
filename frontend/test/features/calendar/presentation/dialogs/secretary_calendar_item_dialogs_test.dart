import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/secretary_calendar_item_dialogs.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

void main() {
  testWidgets('chooser shows the complete label and time range', (
    tester,
  ) async {
    final item = SecretaryCalendarItem.fromAppointment(
      Appointment(
        id: 1,
        scheduleId: 2,
        patientName: 'Ana Pérez',
        date: DateTime(2026, 9, 21),
        startTime: '09:00:00',
        status: 'accepted',
        createdAt: DateTime(2026, 9, 1),
        createdBy: 1,
        updatedAt: DateTime(2026, 9, 1),
        updatedBy: 1,
        doctorId: 3,
        doctorName: 'Dr. Ruiz',
        clinicId: 4,
        clinicName: 'Clínica Central',
        appointmentDuration: 30,
      ),
    );
    SecretaryCalendarItem? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                selected = await showSecretaryCalendarItemChooser(
                  context: context,
                  items: [item],
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Cita - Ana Pérez / Clínica Central'), findsOneWidget);
    expect(find.text('09:00–09:30'), findsOneWidget);

    await tester.tap(find.text('Cita - Ana Pérez / Clínica Central'));
    await tester.pumpAndSettle();

    expect(selected, same(item));
  });

  testWidgets('schedule details expose edit and confirmed delete actions', (
    tester,
  ) async {
    final item = SecretaryCalendarItem.fromSchedule(
      const Schedule(
        id: 8,
        dayOfWeek: 0,
        startTime: '08:00:00',
        endTime: '12:00:00',
        duration: 30,
        doctorId: 3,
        doctorName: 'Dr. Ruiz',
        clinicId: 4,
        clinicName: 'Clínica Central',
      ),
      DateTime(2026, 9, 21),
    );
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showSecretaryBackgroundItemDetails(
                context: context,
                item: item,
                onEditSchedule: () async {},
                onDeleteSchedule: () async => deleted = true,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Editar horario'), findsOneWidget);
    expect(find.text('Eliminar horario'), findsOneWidget);

    await tester.tap(find.text('Eliminar horario'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '¿Deseas eliminar este horario? Esta acción dejará de mostrarlo en el calendario.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });
}
