import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/calendar/presentation/utils/schedule_conflicts.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/app_theme.dart';

/// Aviso inmediato de los horarios existentes que chocan con el que se está
/// configurando. El backend conserva la validación definitiva.
class ScheduleConflictWarning extends StatelessWidget {
  final List<Schedule> conflicts;

  const ScheduleConflictWarning({super.key, required this.conflicts});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('schedule-conflict-warning'),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conflicts.length == 1
                ? 'Este horario entra en conflicto con uno existente'
                : 'Este horario entra en conflicto con ${conflicts.length} '
                      'horarios existentes',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          for (final conflict in conflicts)
            Text(
              '${daysFull[conflict.dayOfWeek]} ${describeScheduleRange(conflict)}'
              '${conflict.clinicName.isEmpty ? '' : ' · ${conflict.clinicName}'}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
