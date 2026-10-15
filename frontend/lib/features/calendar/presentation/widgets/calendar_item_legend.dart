import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_item_icons.dart';

abstract interface class CalendarLegendLeading {
  bool get hasExpandedContent;
}

class CalendarItemLegend extends StatefulWidget {
  final Widget? leading;

  const CalendarItemLegend({super.key, this.leading});

  static const _items = [
    (SecretaryCalendarItemType.appointment, 'Cita'),
    (SecretaryCalendarItemType.schedule, 'Horario'),
    (SecretaryCalendarItemType.blockade, 'Bloqueo'),
  ];

  @override
  State<CalendarItemLegend> createState() => _CalendarItemLegendState();
}

class _CalendarItemLegendState extends State<CalendarItemLegend> {
  bool _mobileCollapsed = false;
  double _verticalDragDistance = 0;

  void _setMobileCollapsed(bool value) {
    if (_mobileCollapsed == value) return;
    setState(() => _mobileCollapsed = value);
  }

  void _onVerticalDragStart(DragStartDetails _) {
    _verticalDragDistance = 0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _verticalDragDistance += details.delta.dy;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_verticalDragDistance < -18 || velocity < -300) {
      _setMobileCollapsed(true);
    } else if (_verticalDragDistance > 18 || velocity > 300) {
      _setMobileCollapsed(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final legend = _LegendContent(foreground: foreground);
          final isMobile = constraints.maxWidth < 650;
          final hasExpandedLeading =
              widget.leading is! CalendarLegendLeading ||
              (widget.leading! as CalendarLegendLeading).hasExpandedContent;
          final padding = isMobile && _mobileCollapsed
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

          if (widget.leading == null) {
            return Padding(
              padding: padding,
              child: Align(alignment: Alignment.topRight, child: legend),
            );
          }

          if (isMobile && !hasExpandedLeading) {
            return Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 48, child: widget.leading!),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(alignment: Alignment.topRight, child: legend),
                  ),
                ],
              ),
            );
          }

          if (isMobile) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: _mobileCollapsed
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                widget.leading!,
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: legend,
                                ),
                              ],
                            ),
                    ),
                    _MobileCollapseHandle(
                      collapsed: _mobileCollapsed,
                      onTap: () => _setMobileCollapsed(!_mobileCollapsed),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: widget.leading!),
                const SizedBox(width: 12),
                legend,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileCollapseHandle extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const _MobileCollapseHandle({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    return Semantics(
      button: true,
      label: collapsed
          ? 'Mostrar filtros y leyenda'
          : 'Ocultar filtros y leyenda',
      child: Tooltip(
        message: collapsed
            ? 'Mostrar filtros y leyenda'
            : 'Ocultar filtros y leyenda',
        child: InkWell(
          key: const ValueKey('calendar-header-drag-handle'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 24,
            child: Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendContent extends StatelessWidget {
  final Color foreground;

  const _LegendContent({required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          children: CalendarItemLegend._items
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
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
    );
  }
}
