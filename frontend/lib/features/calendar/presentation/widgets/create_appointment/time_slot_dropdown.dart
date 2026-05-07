import 'package:flutter/material.dart';

class TimeSlotDropdown extends StatelessWidget {
  final String? selectedTime;
  final List<String> timeSlots;
  final ValueChanged<String?> onChanged;

  const TimeSlotDropdown({
    super.key,
    required this.selectedTime,
    required this.timeSlots,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedTime,
      decoration: const InputDecoration(labelText: 'Hora de la cita'),
      items: timeSlots
          .map((time) => DropdownMenuItem(value: time, child: Text(time)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecciona una hora' : null,
    );
  }
}
