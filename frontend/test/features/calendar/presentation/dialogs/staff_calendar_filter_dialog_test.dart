import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/dialogs/staff_calendar_filter_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/staff_calendar_filter_provider.dart';

void main() {
  testWidgets(
    'doctor filter exposes the requested controls and nested option',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_filterHost(allowDoctorFilter: false));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Paciente'), findsOneWidget);
      expect(find.text('Filtrar ítems por hora:'), findsOneWidget);
      expect(find.text('Desde'), findsOneWidget);
      expect(find.text('Hasta'), findsOneWidget);
      expect(find.text('Filtrar por doctor'), findsNothing);
      expect(find.text('Filtrar por clínica'), findsOneWidget);
      expect(find.text('Mostrar horarios'), findsOneWidget);
      expect(find.text('Mostrar bloqueos'), findsOneWidget);
      expect(find.text('Mostrar citas'), findsOneWidget);
      expect(find.text('Mostrar citas canceladas'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Sin límite'),
        findsNWidgets(2),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Sin límite').first);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      final timePickerButtons = find.descendant(
        of: find.byType(TimePickerDialog),
        matching: find.byType(TextButton),
      );
      expect(timePickerButtons, findsNWidgets(2));
      await tester.tap(timePickerButtons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mostrar citas'));
      await tester.pump();
      expect(find.text('Mostrar citas canceladas'), findsNothing);
    },
  );

  testWidgets('secretary filter includes doctor selection and returns times', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    StaffCalendarFilterState? applied;

    await tester.pumpWidget(
      _filterHost(
        allowDoctorFilter: true,
        initialFilters: const StaffCalendarFilterState(
          startTime: '08:00',
          endTime: '12:00',
        ),
        onApplied: (filters) => applied = filters,
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar por doctor'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '08:00'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '12:00'), findsOneWidget);
    final clearStart = find.descendant(
      of: find.byTooltip('Limpiar Desde'),
      matching: find.byType(InkResponse),
    );
    expect(tester.widget<InkResponse>(clearStart).radius, 13);
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: find.byTooltip('Limpiar Desde'),
              matching: find.byIcon(Icons.close),
            ),
          )
          .size,
      18,
    );
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(applied, isNotNull);
    expect(applied!.startTime, '08:00');
    expect(applied!.endTime, '12:00');
  });

  testWidgets('rejects an end time that is not after the start time', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    StaffCalendarFilterState? applied;

    await tester.pumpWidget(
      _filterHost(
        allowDoctorFilter: false,
        initialFilters: const StaffCalendarFilterState(
          startTime: '12:00',
          endTime: '08:00',
        ),
        onApplied: (filters) => applied = filters,
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar'));
    await tester.pump();

    expect(applied, isNull);
    expect(
      find.text('La hora final debe ser posterior a la inicial.'),
      findsOneWidget,
    );
  });
}

Widget _filterHost({
  required bool allowDoctorFilter,
  StaffCalendarFilterState initialFilters = const StaffCalendarFilterState(),
  ValueChanged<StaffCalendarFilterState>? onApplied,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => FilledButton(
            onPressed: () async {
              final result = await showStaffCalendarFilterDialog(
                context: context,
                ref: ref,
                currentFilters: initialFilters,
                allowDoctorFilter: allowDoctorFilter,
              );
              if (result != null) onApplied?.call(result);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
}
