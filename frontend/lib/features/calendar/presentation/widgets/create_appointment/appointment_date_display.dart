import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/app_theme.dart';

class AppointmentDateDisplay extends StatelessWidget {
  final DateTime selectedDate;
  final Schedule selectedSchedule;

  const AppointmentDateDisplay({
    super.key,
    required this.selectedDate,
    required this.selectedSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Fecha'),
      child: Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}  (${daysFull[selectedSchedule.dayOfWeek]})',
        style: AppTextStyles.body,
      ),
    );
  }
}
