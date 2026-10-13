import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/blockade_detail_dialog.dart';

void main() {
  testWidgets('shows blockade details before confirmed deletion', (
    tester,
  ) async {
    var deleted = false;
    final blockade = Appointment(
      id: 9,
      scheduleId: 2,
      patientName: '',
      date: DateTime(2026, 10, 12),
      startTime: '09:30:00',
      status: 'blockade',
      createdAt: DateTime(2026, 10, 1),
      createdBy: 1,
      updatedAt: DateTime(2026, 10, 1),
      updatedBy: 1,
      doctorId: 3,
      doctorName: 'Dra. Ana Ruiz',
      clinicId: 4,
      clinicName: 'Clínica Central',
      appointmentDuration: 90,
      type: 'blockade',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showBlockadeDetailSheet(
                context: context,
                blockade: blockade,
                onDelete: () async => deleted = true,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Detalles del bloqueo'), findsOneWidget);
    expect(find.text('Dra. Ana Ruiz'), findsOneWidget);
    expect(find.text('Clínica Central'), findsOneWidget);
    expect(find.text('12/10/2026'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);
    expect(
      find.text(
        '¿Deseas eliminar este bloqueo de horario? Esta acción no se puede deshacer.',
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('blockade-delete-action')));
    await tester.pumpAndSettle();
    expect(deleted, isFalse);
    expect(
      find.text(
        '¿Deseas eliminar este bloqueo de horario? Esta acción no se puede deshacer.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();
    expect(deleted, isFalse);
    expect(find.text('Detalles del bloqueo'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('blockade-delete-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(find.text('Detalles del bloqueo'), findsNothing);
    expect(find.text('Bloqueo eliminado'), findsOneWidget);
  });
}
