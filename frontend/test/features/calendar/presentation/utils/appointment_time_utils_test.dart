import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/appointment_date_display.dart';

void main() {
  group('schedule date selection', () {
    test('keeps a future matching weekday from the viewed week', () {
      final result = nextScheduleDate(
        weekStart: DateTime(2026, 9, 7),
        today: DateTime(2026, 9, 6),
        dayOfWeek: 4,
      );

      expect(result, DateTime(2026, 9, 11));
    });

    test('moves a past weekday to its next future occurrence', () {
      final result = nextScheduleDate(
        weekStart: DateTime(2026, 8, 31),
        today: DateTime(2026, 9, 6),
        dayOfWeek: 4,
      );

      expect(result, DateTime(2026, 9, 11));
    });

    test('accepts only non-past dates on the schedule weekday', () {
      final today = DateTime(2026, 9, 6);

      expect(
        isSelectableScheduleDate(
          date: DateTime(2026, 9, 11),
          today: today,
          dayOfWeek: 4,
        ),
        isTrue,
      );
      expect(
        isSelectableScheduleDate(
          date: DateTime(2026, 9, 10),
          today: today,
          dayOfWeek: 4,
        ),
        isFalse,
      );
      expect(
        isSelectableScheduleDate(
          date: DateTime(2026, 9, 4),
          today: today,
          dayOfWeek: 4,
        ),
        isFalse,
      );
    });
  });

  testWidgets('date field shows only the date and handles taps', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentDateDisplay(
            selectedDate: DateTime(2026, 9, 11),
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('11/9/2026'), findsOneWidget);
    expect(find.textContaining('Viernes'), findsNothing);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );

    await tester.tap(find.text('11/9/2026'));
    expect(taps, 1);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    expect(taps, 2);
  });
}
