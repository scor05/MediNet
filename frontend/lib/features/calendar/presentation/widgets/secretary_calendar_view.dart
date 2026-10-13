import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_collision_layout.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_item_icons.dart';
import 'package:frontend/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_appointment_highlight.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_item_legend.dart';
import 'package:frontend/features/calendar/presentation/widgets/time_column.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_header.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/calendar_theme.dart';

class SecretaryCalendarView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final List<Schedule> schedules;
  final int? highlightedAppointmentId;
  final int? highlightedBlockadeId;
  final ScrollController? verticalScrollController;
  final ValueChanged<List<SecretaryCalendarItem>> onItemsTap;

  const SecretaryCalendarView({
    super.key,
    required this.weekStart,
    required this.appointments,
    required this.schedules,
    this.highlightedAppointmentId,
    this.highlightedBlockadeId,
    this.verticalScrollController,
    required this.onItemsTap,
  });

  static const startHour = 6;
  static const endHour = 18;
  static const hourHeight = 80.0;
  static const timeColumnWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < 800
            ? 800.0
            : constraints.maxWidth;
        return Column(
          children: [
            const CalendarItemLegend(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, calendarConstraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentWidth,
                    height: calendarConstraints.maxHeight,
                    child: Column(
                      children: [
                        WeekHeader(
                          days: days,
                          timeColumnWidth: timeColumnWidth,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: verticalScrollController,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(7, (index) {
                                        final day = days[index];
                                        final dayAppointments = appointments
                                            .where(
                                              (item) =>
                                                  _sameDay(item.date, day),
                                            )
                                            .map(
                                              SecretaryCalendarItem
                                                  .fromAppointment,
                                            )
                                            .toList();
                                        final daySchedules = schedules
                                            .where(
                                              (item) => item.dayOfWeek == index,
                                            )
                                            .map(
                                              (item) =>
                                                  SecretaryCalendarItem.fromSchedule(
                                                    item,
                                                    day,
                                                  ),
                                            )
                                            .toList();

                                        return Expanded(
                                          child: _SecretaryDayColumn(
                                            dayIndex: index,
                                            items: [
                                              ...daySchedules,
                                              ...dayAppointments,
                                            ],
                                            highlightedAppointmentId:
                                                highlightedAppointmentId,
                                            highlightedBlockadeId:
                                                highlightedBlockadeId,
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
  final int? highlightedAppointmentId;
  final int? highlightedBlockadeId;
  final ValueChanged<List<SecretaryCalendarItem>> onItemsTap;

  const _SecretaryDayColumn({
    required this.dayIndex,
    required this.items,
    required this.highlightedAppointmentId,
    required this.highlightedBlockadeId,
    required this.onItemsTap,
  });

  static const _startMinute = SecretaryCalendarView.startHour * 60;
  static const _endMinute = SecretaryCalendarView.endHour * 60;
  static const _gap = 2.0;
  static const _dayEdgeInset = CalendarSizes.calendarItemDayEdgeInset;

  @override
  Widget build(BuildContext context) {
    final schedules = _visibleItems(SecretaryCalendarItemType.schedule);
    final blockades = _visibleItems(SecretaryCalendarItemType.blockade);
    final appointments = _visibleItems(SecretaryCalendarItemType.appointment);
    final schedulePlacements = layoutCalendarCollisions(schedules);
    final blockadePlacements = _placeBlockades(blockades, schedulePlacements);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          key: ValueKey('secretary-day-column-$dayIndex'),
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
                placements: schedulePlacements,
              ),
              ..._buildLayer(
                context,
                blockades,
                constraints.maxWidth,
                opacity: 0.52,
                placements: blockadePlacements,
              ),
              ..._buildLayer(
                context,
                appointments,
                constraints.maxWidth,
                opacity: 1,
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
    List<CalendarCollisionPlacement>? placements,
  }) {
    final resolvedPlacements =
        placements ?? layoutCalendarCollisions(layerItems);
    return resolvedPlacements.map((placement) {
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
      // The day gutter belongs to the outer edges of the collision block.
      // Adjacent items inside the same day only retain the collision gap.
      final usableWidth = availableWidth - (_dayEdgeInset * 2);
      final gaps = _gap * (placement.columnCount - 1);
      final width = (usableWidth - gaps) / placement.columnCount;
      final left = _dayEdgeInset + placement.column * (width + _gap);

      return Positioned(
        key: ValueKey(
          'secretary-calendar-${placement.item.type.name}-'
          '${placement.item.id}',
        ),
        top: top,
        left: left,
        width: width,
        height: height,
        child: placement.item.type != SecretaryCalendarItemType.schedule
            ? CalendarAppointmentHighlight(
                appointmentId:
                    placement.item.type == SecretaryCalendarItemType.blockade
                    ? -placement.item.id
                    : placement.item.id,
                highlighted:
                    placement.item.type == SecretaryCalendarItemType.blockade
                    ? placement.item.id == highlightedBlockadeId
                    : placement.item.id == highlightedAppointmentId,
                glowColor:
                    placement.item.type == SecretaryCalendarItemType.blockade
                    ? CalendarColors.appointmentBlockade
                    : appointmentStatusColor(
                        placement.item.appointment!.status,
                      ),
                child: _calendarCard(
                  placement.item,
                  opacity,
                  clippedStart,
                  clippedEnd,
                ),
              )
            : _calendarCard(placement.item, opacity, clippedStart, clippedEnd),
      );
    }).toList();
  }

  List<CalendarCollisionPlacement> _placeBlockades(
    List<SecretaryCalendarItem> blockades,
    List<CalendarCollisionPlacement> schedulePlacements,
  ) {
    final result = <CalendarCollisionPlacement>[];
    final unmatched = <SecretaryCalendarItem>[];

    for (final blockade in blockades) {
      CalendarCollisionPlacement? matchingSchedule;
      for (final placement in schedulePlacements) {
        if (placement.item.id == blockade.appointment!.scheduleId) {
          matchingSchedule = placement;
          break;
        }
      }

      if (matchingSchedule == null) {
        unmatched.add(blockade);
        continue;
      }

      result.add(
        CalendarCollisionPlacement(
          item: blockade,
          column: matchingSchedule.column,
          columnCount: matchingSchedule.columnCount,
        ),
      );
    }

    result.addAll(layoutCalendarCollisions(unmatched));
    return result;
  }

  Widget _calendarCard(
    SecretaryCalendarItem item,
    double opacity,
    int clippedStart,
    int clippedEnd,
  ) {
    return _SecretaryCalendarCard(
      item: item,
      opacity: opacity,
      onTapAt: (tapFraction) {
        final tapMinute =
            clippedStart + (clippedEnd - clippedStart) * tapFraction;
        onItemsTap(_itemsForTap(item, tapMinute));
      },
    );
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
  final double opacity;
  final ValueChanged<double> onTapAt;

  const _SecretaryCalendarCard({
    required this.item,
    required this.opacity,
    required this.onTapAt,
  });

  @override
  Widget build(BuildContext context) {
    final base = switch (item.type) {
      SecretaryCalendarItemType.schedule => CalendarColors.schedule,
      SecretaryCalendarItemType.blockade => CalendarColors.appointmentBlockade,
      SecretaryCalendarItemType.appointment => appointmentStatusColor(
        item.appointment!.status,
      ),
    };
    final borderColor = item.type == SecretaryCalendarItemType.appointment
        ? Color.alphaBlend(Colors.black26, base)
        : base.withValues(alpha: 0.85);
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
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Align(
                alignment: item.type == SecretaryCalendarItemType.schedule
                    ? Alignment.topCenter
                    : Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      calendarItemIcon(item.type),
                      size: 13,
                      color: foreground,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        item.type == SecretaryCalendarItemType.appointment
                            ? item.appointment!.patientName
                            : item.doctorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: foreground,
                          fontSize:
                              item.type == SecretaryCalendarItemType.schedule
                              ? CalendarSizes.itemFontSize
                              : CalendarSizes.appointmentTimeFontSize,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
