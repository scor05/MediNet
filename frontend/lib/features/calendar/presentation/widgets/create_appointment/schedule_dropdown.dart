import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class ScheduleDropdown extends StatelessWidget {
  final List<Schedule> schedules;
  final Schedule? selectedSchedule;
  final ValueChanged<Schedule?> onChanged;

  const ScheduleDropdown({
    super.key,
    required this.schedules,
    required this.selectedSchedule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Schedule>(
      initialValue: selectedSchedule,
      decoration: const InputDecoration(labelText: 'Horario'),
      items: schedules
          .map(
            (schedule) => DropdownMenuItem(
              value: schedule,
              child: Text(
                '${daysFull[schedule.dayOfWeek]} - ${schedule.clinicName} (${schedule.startTime}–${schedule.endTime})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecciona un horario' : null,
    );
  }
}
