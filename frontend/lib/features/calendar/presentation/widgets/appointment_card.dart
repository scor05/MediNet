import 'package:flutter/material.dart';
import '../../domain/entities/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  Color _statusColor() {
    return switch (appointment.status) {
      'accepted' => Colors.green.shade100,
      'requested' => Colors.orange.shade100,
      'cancelled' => Colors.red.shade100,
      _ => Colors.grey.shade100,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _statusColor(),
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.startTime,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              appointment.patientName!,
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              appointment.clinicName,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
