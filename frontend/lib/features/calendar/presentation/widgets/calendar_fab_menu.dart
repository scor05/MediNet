import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/widgets/fab_menu_item.dart';
import 'package:frontend/theme/calendar_theme.dart';

class CalendarFabMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onCreateAppointment;
  final VoidCallback onCreateSchedule;

  const CalendarFabMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.onCreateAppointment,
    required this.onCreateSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isOpen) ...[
            FabMenuItem(
              label: 'Nueva cita',
              icon: Icons.event_available,
              color: CalendarColors.createAppointmentFab,
              onTap: onCreateAppointment,
            ),
            const SizedBox(height: 8),
            FabMenuItem(
              label: 'Nuevo horario',
              icon: Icons.schedule,
              color: CalendarColors.createScheduleFab,
              onTap: onCreateSchedule,
            ),
          ],
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: onToggle,
            child: AnimatedRotation(
              turns: isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
