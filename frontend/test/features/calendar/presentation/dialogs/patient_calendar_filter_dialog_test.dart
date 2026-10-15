import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/dialogs/patient_calendar_filter_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_filter_provider.dart';

void main() {
  testWidgets('clear filters returns the patient calendar defaults', (
    tester,
  ) async {
    PatientCalendarFilterState? applied;

    await tester.pumpWidget(
      _filterHost(
        initialFilters: const PatientCalendarFilterState(
          doctorId: 10,
          doctorName: 'Doctor',
          clinicId: 20,
          clinicName: 'Clínica',
          showCancelled: false,
        ),
        onApplied: (filters) => applied = filters,
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpiar Filtros'));
    await tester.pumpAndSettle();

    expect(applied, isNotNull);
    expect(applied!.hasFilters, isFalse);
    expect(applied!.doctorId, isNull);
    expect(applied!.clinicId, isNull);
    expect(applied!.showCancelled, isTrue);
  });
}

Widget _filterHost({
  required PatientCalendarFilterState initialFilters,
  ValueChanged<PatientCalendarFilterState>? onApplied,
}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => FilledButton(
            onPressed: () async {
              final result = await showPatientCalendarFilterDialog(
                context: context,
                ref: ref,
                currentFilters: initialFilters,
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
