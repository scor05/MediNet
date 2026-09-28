import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/widgets/secretary_calendar_view.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';

void main() {
  testWidgets('weekly calendar remains readable on a mobile web viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeekView(
            weekStart: DateTime(2026, 9, 28),
            appointments: const [],
            schedules: const [],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const ValueKey('calendar-day-column-0'))).width,
      greaterThan(90),
    );
  });

  testWidgets('secretary calendar remains readable on a mobile web viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 28),
            appointments: const [],
            schedules: const [],
            doctorColors: const {},
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('secretary-day-column-0')))
          .width,
      greaterThan(90),
    );
  });
}
