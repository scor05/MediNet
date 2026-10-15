import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_filter_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/staff_calendar_filter_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_filter_summary.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_item_legend.dart';

void main() {
  testWidgets('shows only the filter button for default filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarItemLegend(
            leading: CalendarFilterSummary.forPatient(
              filters: const PatientCalendarFilterState(),
              onChanged: (_) {},
              onOpenFilters: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('calendar-filter-button')),
      findsOneWidget,
    );
    expect(find.text('Filtros activos'), findsNothing);
  });

  testWidgets('keeps the mobile filter button beside the default legend', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarItemLegend(
            leading: CalendarFilterSummary.forPatient(
              filters: const PatientCalendarFilterState(),
              onChanged: (_) {},
              onOpenFilters: () {},
            ),
          ),
        ),
      ),
    );

    final filterButton = find.byKey(const ValueKey('calendar-filter-button'));
    expect(find.text('Filtros activos'), findsNothing);
    expect(
      find.byKey(const ValueKey('calendar-header-drag-handle')),
      findsNothing,
    );
    expect(
      (tester.getCenter(filterButton).dy -
              tester.getCenter(find.text('Leyenda')).dy)
          .abs(),
      lessThan(20),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows active staff filters and removes one from its chip', (
    tester,
  ) async {
    const filters = StaffCalendarFilterState(
      patientId: 8,
      patientName: 'Ana Pérez',
      filterDoctor: true,
      doctorId: 4,
      doctorName: 'Dr. Ruiz',
      filterClinic: true,
      clinicId: 2,
      clinicName: 'Clínica Central',
      startTime: '08:30',
      showSchedules: false,
      showCancelled: false,
    );
    StaffCalendarFilterState? updated;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarItemLegend(
            leading: CalendarFilterSummary.forStaff(
              filters: filters,
              showDoctorFilter: true,
              onChanged: (value) => updated = value,
              onOpenFilters: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Filtros activos'), findsOneWidget);
    expect(find.text('Paciente: Ana Pérez'), findsOneWidget);
    expect(find.text('Doctor: Dr. Ruiz'), findsOneWidget);
    expect(find.text('Clínica: Clínica Central'), findsOneWidget);
    expect(find.text('Desde: 08:30'), findsOneWidget);
    expect(find.text('Ocultar horarios'), findsOneWidget);
    expect(find.text('Ocultar canceladas'), findsOneWidget);

    final patientChip = find.byKey(
      const ValueKey('active-calendar-filter-Paciente: Ana Pérez'),
    );
    await tester.tap(
      find.descendant(of: patientChip, matching: find.byIcon(Icons.close)),
    );

    expect(updated, isNotNull);
    expect(updated!.patientId, isNull);
    expect(updated!.doctorId, filters.doctorId);
    expect(updated!.clinicId, filters.clinicId);
    expect(updated!.showSchedules, isFalse);
  });

  testWidgets('active filters wrap without overflowing a mobile viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarItemLegend(
            leading: CalendarFilterSummary.forStaff(
              filters: const StaffCalendarFilterState(
                patientId: 8,
                patientName: 'Ana Pérez',
                startTime: '08:30',
                endTime: '12:00',
                showSchedules: false,
                showBlockades: false,
              ),
              showDoctorFilter: false,
              onChanged: (_) {},
              onOpenFilters: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Filtros activos'), findsOneWidget);
    final handle = find.byKey(const ValueKey('calendar-header-drag-handle'));
    expect(handle, findsOneWidget);

    await tester.drag(handle, const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(find.text('Filtros activos'), findsNothing);
    expect(find.text('Leyenda'), findsNothing);
    expect(handle, findsOneWidget);

    await tester.drag(handle, const Offset(0, 80));
    await tester.pumpAndSettle();

    expect(find.text('Filtros activos'), findsOneWidget);
    expect(find.text('Leyenda'), findsOneWidget);
  });
}
