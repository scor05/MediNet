import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AppointmentDateDisplay extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const AppointmentDateDisplay({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}
