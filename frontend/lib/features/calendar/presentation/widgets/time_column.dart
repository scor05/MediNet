import 'package:flutter/material.dart';
import 'package:frontend/theme/calendar_theme.dart';

class TimeColumn extends StatelessWidget {
  final int startHour;
  final int endHour;
  final double hourHeight;
  final double width;

  const TimeColumn({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.width,
  });

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: (endHour - startHour) * hourHeight,
      child: Column(
        children: List.generate(endHour - startHour, (i) {
          final hour = startHour + i;

          return SizedBox(
            height: hourHeight,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: CalendarSizes.hourRightPadding,
                  top: CalendarSizes.hourTopPadding,
                ),
                child: Text(
                  _formatHour(hour),
                  style: CalendarTextStyles.hourLabel(context),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
