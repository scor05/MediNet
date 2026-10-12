import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_item_icons.dart';

class CalendarItemLegend extends StatelessWidget {
  const CalendarItemLegend({super.key});

  static const _items = [
    (SecretaryCalendarItemType.appointment, 'Cita'),
    (SecretaryCalendarItemType.schedule, 'Horario'),
    (SecretaryCalendarItemType.blockade, 'Bloqueo'),
  ];

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Leyenda',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 14,
            runSpacing: 4,
            children: _items
                .map(
                  (item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        calendarItemIcon(item.$1),
                        size: 22,
                        color: foreground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w300,
                            ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
