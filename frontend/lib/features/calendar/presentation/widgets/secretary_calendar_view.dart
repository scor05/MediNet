import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_collision_layout.dart';
import 'package:frontend/features/calendar/presentation/widgets/time_column.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_header.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/calendar_theme.dart';

class SecretaryCalendarView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final List<Schedule> schedules;
  final Map<int, Color> doctorColors;
  final ValueChanged<List<SecretaryCalendarItem>> onItemsTap;

  const SecretaryCalendarView({
    super.key,
    required this.weekStart,
    required this.appointments,
    required this.schedules,
    required this.doctorColors,
    required this.onItemsTap,
  });

  static const startHour = 6;
  static const endHour = 18;
  static const hourHeight = 80.0;
  static const timeColumnWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        WeekHeader(days: days, timeColumnWidth: timeColumnWidth),
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TimeColumn(
                  startHour: startHour,
                  endHour: endHour,
                  hourHeight: hourHeight,
                  width: timeColumnWidth,
                ),
                Expanded(
                  child: SizedBox(
                    height: (endHour - startHour) * hourHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(7, (index) {
                        final day = days[index];
                        final dayAppointments = appointments
                            .where((item) => _sameDay(item.date, day))
                            .map(SecretaryCalendarItem.fromAppointment)
                            .toList();
                        final daySchedules = schedules
                            .where((item) => item.dayOfWeek == index)
                            .map(
                              (item) =>
                                  SecretaryCalendarItem.fromSchedule(item, day),
                            )
                            .toList();

                        return Expanded(
                          child: _SecretaryDayColumn(
                            dayIndex: index,
                            items: [...daySchedules, ...dayAppointments],
                            doctorColors: doctorColors,
                            onItemsTap: onItemsTap,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _SecretaryDayColumn extends StatelessWidget {
  final int dayIndex;
  final List<SecretaryCalendarItem> items;
  final Map<int, Color> doctorColors;
  final ValueChanged<List<SecretaryCalendarItem>> onItemsTap;

  const _SecretaryDayColumn({
    required this.dayIndex,
    required this.items,
    required this.doctorColors,
    required this.onItemsTap,
  });

  static const _startMinute = SecretaryCalendarView.startHour * 60;
  static const _endMinute = SecretaryCalendarView.endHour * 60;
  static const _gap = 2.0;
  static const _horizontalInset = 2.0;

  @override
  Widget build(BuildContext context) {
    final schedules = _visibleItems(SecretaryCalendarItemType.schedule);
    final blockades = _visibleItems(SecretaryCalendarItemType.blockade);
    final appointments = _visibleItems(SecretaryCalendarItemType.appointment);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              right: dayIndex < 6
                  ? BorderSide(
                      color: CalendarColors.divider(context),
                      width: CalendarSizes.dividerWidth,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              _hourGrid(context),
              ..._buildLayer(
                context,
                schedules,
                constraints.maxWidth,
                opacity: 0.25,
              ),
              ..._buildLayer(
                context,
                blockades,
                constraints.maxWidth,
                opacity: 0.52,
              ),
              ..._buildLayer(
                context,
                appointments,
                constraints.maxWidth,
                opacity: 0.82,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hourGrid(BuildContext context) {
    return Column(
      children: List.generate(
        SecretaryCalendarView.endHour - SecretaryCalendarView.startHour,
        (_) => Container(
          height: SecretaryCalendarView.hourHeight,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CalendarColors.divider(context),
                width: CalendarSizes.dividerWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<SecretaryCalendarItem> _visibleItems(SecretaryCalendarItemType type) {
    return items
        .where(
          (item) =>
              item.type == type &&
              item.endMinute > _startMinute &&
              item.startMinute < _endMinute,
        )
        .toList();
  }

  List<Widget> _buildLayer(
    BuildContext context,
    List<SecretaryCalendarItem> layerItems,
    double availableWidth, {
    required double opacity,
  }) {
    final placements = layoutCalendarCollisions(layerItems);
    return placements.map((placement) {
      final clippedStart = placement.item.startMinute.clamp(
        _startMinute,
        _endMinute,
      );
      final clippedEnd = placement.item.endMinute.clamp(
        _startMinute,
        _endMinute,
      );
      final top =
          (clippedStart - _startMinute) *
          (SecretaryCalendarView.hourHeight / 60);
      final height =
          (clippedEnd - clippedStart) * (SecretaryCalendarView.hourHeight / 60);
      final usableWidth = availableWidth - (_horizontalInset * 2);
      final gaps = _gap * (placement.columnCount - 1);
      final width = (usableWidth - gaps) / placement.columnCount;
      final left = _horizontalInset + placement.column * (width + _gap);

      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: _SecretaryCalendarCard(
          item: placement.item,
          doctorColor: doctorColors[placement.item.doctorId] ?? Colors.blueGrey,
          opacity: opacity,
          onTapAt: (tapFraction) {
            final tapMinute =
                clippedStart + (clippedEnd - clippedStart) * tapFraction;
            onItemsTap(_itemsForTap(placement.item, tapMinute));
          },
        ),
      );
    }).toList();
  }

  List<SecretaryCalendarItem> _itemsForTap(
    SecretaryCalendarItem selected,
    double minute,
  ) {
    final result = <SecretaryCalendarItem>[selected];
    for (final item in items) {
      if (identical(item, selected) || item.type == selected.type) continue;
      if (item.containsMinute(minute)) result.add(item);
    }
    result.sort((a, b) => _layerOrder(b.type).compareTo(_layerOrder(a.type)));
    return result;
  }

  int _layerOrder(SecretaryCalendarItemType type) => switch (type) {
    SecretaryCalendarItemType.schedule => 0,
    SecretaryCalendarItemType.blockade => 1,
    SecretaryCalendarItemType.appointment => 2,
  };
}

class _SecretaryCalendarCard extends StatelessWidget {
  final SecretaryCalendarItem item;
  final Color doctorColor;
  final double opacity;
  final ValueChanged<double> onTapAt;

  const _SecretaryCalendarCard({
    required this.item,
    required this.doctorColor,
    required this.opacity,
    required this.onTapAt,
  });

  @override
  Widget build(BuildContext context) {
    final isBlockade = item.type == SecretaryCalendarItemType.blockade;
    final base = isBlockade ? Colors.red.shade200 : doctorColor;
    final background = Color.alphaBlend(
      base.withValues(alpha: opacity),
      Theme.of(context).colorScheme.surface,
    );
    final foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 105;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final fraction = constraints.maxHeight == 0
                ? 0.0
                : (details.localPosition.dy / constraints.maxHeight).clamp(
                    0.0,
                    0.999,
                  );
            onTapAt(fraction);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isBlockade
                    ? Colors.red.shade400
                    : doctorColor.withValues(alpha: 0.85),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compact ? item.shortLabel : item.fullLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 10,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (constraints.maxHeight >= 31)
                    Text(
                      item.timeRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.8),
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
