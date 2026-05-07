import 'package:flutter/material.dart';
import 'package:frontend/theme/calendar_theme.dart';

class WeekHeader extends StatelessWidget {
  final List<DateTime> days;
  final double timeColumnWidth;

  const WeekHeader({
    super.key,
    required this.days,
    required this.timeColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final today = DateTime.now();

    return Row(
      children: [
        SizedBox(width: timeColumnWidth),
        Expanded(
          child: IntrinsicHeight(
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
                          ? CalendarColors.todayHeader(context)
                          : CalendarColors.normalHeader(context),
                      border: Border(
                        right: i < 6
                            ? BorderSide(
                                color: CalendarColors.divider(context),
                                width: CalendarSizes.dividerWidth,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: CalendarSizes.headerVerticalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNames[i],
                          style: CalendarTextStyles.dayName(
                            context,
                            isToday: isToday,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.day}',
                          style: CalendarTextStyles.dayNumber(
                            context,
                            isToday: isToday,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
