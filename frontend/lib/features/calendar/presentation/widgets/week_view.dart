import 'package:flutter/material.dart';
import '../../domain/entities/appointment.dart';
import 'appointment_card.dart';

class WeekView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> appointments;

  const WeekView({
    super.key,
    required this.weekStart,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Row(
      children: List.generate(7, (i) {
        final day = days[i];
        final dayAppts = appointments
            .where(
              (a) =>
                  a.date.year == day.year &&
                  a.date.month == day.month &&
                  a.date.day == day.day,
            )
            .toList();

        return Expanded(
          child: Column(
            children: [
              // Header del día
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  children: [
                    Text(
                      dayNames[i],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${day.day}/${day.month}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Citas del día
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(4),
                  children: dayAppts
                      .map((a) => AppointmentCard(appointment: a))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
