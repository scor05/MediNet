import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/data/models/public_slot_model.dart';

void main() {
  Map<String, dynamic> slotJson({bool? isOccupied}) {
    return {
      'schedule_id': 12,
      'start_time': '09:00',
      'end_time': '09:30',
      'is_occupied': ?isOccupied,
      'doctor': {'id': 4, 'name': 'Dra. Lopez'},
      'clinic': {'id': 6, 'name': 'Zona 15'},
    };
  }

  test('decodes an occupied public slot', () {
    final slot = PublicSlotModel.fromJson(slotJson(isOccupied: true));

    expect(slot.isOccupied, isTrue);
    expect(slot.scheduleId, 12);
    expect(slot.startTime, '09:00');
  });

  test('treats the slot as free when an older API omits the marker', () {
    final slot = PublicSlotModel.fromJson(slotJson());

    expect(slot.isOccupied, isFalse);
  });
}
