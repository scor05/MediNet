import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_collision_layout.dart';

void main() {
  test('assigns columns within each connected overlap group', () {
    final first = _item(1, '08:00', 120);
    final second = _item(2, '08:30', 30);
    final third = _item(3, '09:00', 30);
    final separate = _item(4, '11:00', 30);

    final placements = layoutCalendarCollisions([
      first,
      second,
      third,
      separate,
    ]);

    expect(_placement(placements, 1).column, 0);
    expect(_placement(placements, 2).column, 1);
    expect(_placement(placements, 3).column, 1);
    expect(_placement(placements, 1).columnCount, 2);
    expect(_placement(placements, 3).columnCount, 2);
    expect(_placement(placements, 4).column, 0);
    expect(_placement(placements, 4).columnCount, 1);
  });

  test('items that only touch at an endpoint do not collide', () {
    final placements = layoutCalendarCollisions([
      _item(1, '08:00', 30),
      _item(2, '08:30', 30),
    ]);

    expect(placements.every((item) => item.columnCount == 1), isTrue);
  });
}

CalendarCollisionPlacement _placement(
  List<CalendarCollisionPlacement> placements,
  int id,
) => placements.singleWhere((placement) => placement.item.id == id);

SecretaryCalendarItem _item(int id, String startTime, int duration) {
  return SecretaryCalendarItem.fromAppointment(
    Appointment(
      id: id,
      scheduleId: 1,
      patientName: 'Paciente $id',
      date: DateTime(2026, 9, 21),
      startTime: startTime,
      status: 'accepted',
      createdAt: DateTime(2026, 9, 1),
      createdBy: 1,
      updatedAt: DateTime(2026, 9, 1),
      updatedBy: 1,
      doctorId: 9,
      doctorName: 'Doctor',
      clinicId: 3,
      clinicName: 'Clínica',
      appointmentDuration: duration,
    ),
  );
}
