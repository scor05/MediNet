import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/appointment_card.dart';

class WeekView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final bool showDoctor;

  const WeekView({
    super.key,
    required this.weekStart,
    required this.appointments,
    this.showDoctor = false,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final today = DateTime.now();

    return Column(
      children: [
        // Header de días
        IntrinsicHeight(
          child: Row(
            children: List.generate(7, (i) {
              final day = days[i];
              final isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border(
                      right: i < 6
                          ? BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: isToday
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isToday
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),

        // Columna de citas
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: i < 6
                          ? BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    children: dayAppts.isEmpty
                        ? [const SizedBox.shrink()]
                        : dayAppts
                              .map(
                                (a) => AppointmentCard(
                                  appointment: a,
                                  showDoctor: showDoctor,
                                ),
                              )
                              .toList(),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
