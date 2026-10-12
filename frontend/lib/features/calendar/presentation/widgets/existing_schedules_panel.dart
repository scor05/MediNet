import 'package:flutter/material.dart';
import 'package:frontend/core/utils/time_format.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/app_theme.dart';

/// Horarios que un doctor ya tiene en una clínica, agrupados por día, para
/// identificar espacios libres antes de crear un horario nuevo.
class ExistingSchedulesPanel extends StatelessWidget {
  final List<Schedule> schedules;
  final bool loading;
  final String? error;

  /// Texto bajo el título, por ejemplo "Dr Figueroa · Zona 15".
  final String subtitle;

  const ExistingSchedulesPanel({
    super.key,
    required this.schedules,
    required this.loading,
    required this.subtitle,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('existing-schedules-panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios existentes',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _body(),
        ],
      ),
    );
  }

  Widget _body() {
    if (loading) {
      return const Row(
        key: ValueKey('existing-schedules-loading'),
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Consultando horarios…', style: TextStyle(fontSize: 12)),
        ],
      );
    }

    if (error != null) {
      return Text(
        error!,
        key: const ValueKey('existing-schedules-error'),
        style: const TextStyle(fontSize: 12, color: AppColors.error),
      );
    }

    if (schedules.isEmpty) {
      return const Text(
        'Sin horarios en esta clínica. Todos los días están disponibles.',
        key: ValueKey('existing-schedules-empty'),
        style: TextStyle(fontSize: 12, color: AppColors.success),
      );
    }

    final byDay = <int, List<Schedule>>{};
    for (final schedule in schedules) {
      byDay.putIfAbsent(schedule.dayOfWeek, () => []).add(schedule);
    }
    final days = byDay.keys.toList()..sort();
    final freeDays = [
      for (var day = 0; day < daysFull.length; day++)
        if (!byDay.containsKey(day)) daysFull[day],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in days)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              key: ValueKey('existing-schedules-day-$day'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    daysFull[day],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _ranges(byDay[day]!),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        if (freeDays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Sin horario: ${freeDays.join(', ')}',
              key: const ValueKey('existing-schedules-free-days'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  static String _ranges(List<Schedule> daySchedules) {
    final sorted = [...daySchedules]
      ..sort(
        (a, b) =>
            formatTime24(a.startTime).compareTo(formatTime24(b.startTime)),
      );
    return sorted
        .map(
          (item) =>
              '${formatTime24(item.startTime)}–${formatTime24(item.endTime)}',
        )
        .join(' · ');
  }
}
