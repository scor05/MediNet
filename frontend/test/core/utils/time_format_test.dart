import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/time_format.dart';

void main() {
  group('formatTime24', () {
    test('formats morning and afternoon times as HH:mm', () {
      expect(formatTime24('08:05:00'), '08:05');
      expect(formatTime24('15:30:00'), '15:30');
    });
  });

  group('calculateEndTime24', () {
    test('calculates appointment end time in 24-hour format', () {
      expect(calculateEndTime24('08:30:00', 30), '09:00');
      expect(calculateEndTime24('13:45:00', 30), '14:15');
    });

    test('pads midnight hours', () {
      expect(calculateEndTime24('23:45:00', 30), '00:15');
    });
  });
}
