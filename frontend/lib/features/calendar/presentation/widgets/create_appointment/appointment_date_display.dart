import 'package:flutter/material.dart';

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
    final formattedDate =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return TextFormField(
      key: ValueKey(formattedDate),
      initialValue: formattedDate,
      readOnly: true,
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      decoration: InputDecoration(
        labelText: 'Fecha',
        suffixIcon: IconButton(
          tooltip: 'Seleccionar fecha',
          onPressed: onTap,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }
}
