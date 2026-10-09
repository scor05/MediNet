import 'package:flutter/material.dart';

class CalendarAppointmentHighlight extends StatefulWidget {
  final int appointmentId;
  final bool highlighted;
  final Color glowColor;
  final Widget child;

  const CalendarAppointmentHighlight({
    super.key,
    required this.appointmentId,
    required this.highlighted,
    required this.glowColor,
    required this.child,
  });

  @override
  State<CalendarAppointmentHighlight> createState() =>
      _CalendarAppointmentHighlightState();
}

class _CalendarAppointmentHighlightState
    extends State<CalendarAppointmentHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;
  int _completedPulses = 0;
  bool _isPulsing = false;
  bool _showGlow = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addStatusListener(_handleAnimationStatus);
    _glow = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );

    if (widget.highlighted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startPulses();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CalendarAppointmentHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.highlighted && widget.highlighted) {
      _startPulses();
    } else if (oldWidget.highlighted && !widget.highlighted) {
      _stopPulses();
    }
  }

  void _startPulses() {
    _completedPulses = 0;
    _isPulsing = true;
    _showGlow = true;
    _controller.forward(from: 0);
  }

  void _stopPulses() {
    _isPulsing = false;
    _showGlow = false;
    _controller.stop();
    _controller.value = 0;
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (!_isPulsing) return;

    if (status == AnimationStatus.completed) {
      _controller.reverse();
      return;
    }

    if (status != AnimationStatus.dismissed) return;

    _completedPulses++;
    if (_completedPulses < 3) {
      _controller.forward();
      return;
    }

    _isPulsing = false;
    if (mounted) setState(() => _showGlow = false);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourceHsl = HSLColor.fromColor(widget.glowColor);
    final highlightColor = sourceHsl
        .withSaturation(
          sourceHsl.saturation < 0.65 ? 0.65 : sourceHsl.saturation,
        )
        .withLightness(
          Theme.of(context).brightness == Brightness.dark ? 0.68 : 0.42,
        )
        .toColor();

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              key: ValueKey('appointment-highlight-${widget.appointmentId}'),
              animation: _glow,
              builder: (context, _) {
                final intensity = _showGlow ? _glow.value : 0.0;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: intensity == 0
                        ? const []
                        : [
                            BoxShadow(
                              color: highlightColor.withValues(
                                alpha: 0.85 * intensity,
                              ),
                              blurRadius: 4 + (12 * intensity),
                              spreadRadius: 1 + (3 * intensity),
                            ),
                          ],
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
