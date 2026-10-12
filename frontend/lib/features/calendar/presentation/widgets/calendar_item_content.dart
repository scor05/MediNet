import 'package:flutter/material.dart';
import 'package:frontend/theme/calendar_theme.dart';

/// Contenido de un elemento del calendario con jerarquía fija:
/// tipo, paciente o doctor, clínica y rango de horas.
///
/// El tamaño de fuente no cambia: cuando la altura no alcanza se muestran
/// solo las primeras líneas, y cada línea se recorta con puntos suspensivos
/// si no cabe en el ancho.
class CalendarItemContent extends StatelessWidget {
  final String type;
  final String? person;
  final String? clinic;
  final String timeRange;
  final Color color;

  /// Ancla el texto al borde inferior. Se usa en los horarios, que quedan
  /// debajo de las citas y bloqueos, para que estos no lo tapen.
  final bool anchorBottom;

  const CalendarItemContent({
    super.key,
    required this.type,
    this.person,
    this.clinic,
    required this.timeRange,
    required this.color,
    this.anchorBottom = false,
  });

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final lines = <_ItemLine>[
      _ItemLine(type, FontWeight.w600, 0.9),
      if (_hasText(person)) _ItemLine(person!.trim(), FontWeight.w700, 1),
      if (_hasText(clinic)) _ItemLine(clinic!.trim(), FontWeight.w400, 0.9),
      _ItemLine(timeRange, FontWeight.w400, 0.8),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const lineHeight =
            CalendarSizes.itemFontSize * CalendarSizes.itemLineHeight;
        final visibleCount = constraints.hasBoundedHeight
            ? ((constraints.maxHeight - CalendarSizes.itemVerticalPadding * 2) /
                      lineHeight)
                  .floor()
                  .clamp(1, lines.length)
            : lines.length;

        // OverflowBox evita errores de layout cuando el elemento es más
        // bajo que una sola línea; ClipRect oculta lo que sobresale.
        return ClipRect(
          child: OverflowBox(
            alignment: anchorBottom ? Alignment.bottomLeft : Alignment.topLeft,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CalendarSizes.itemHorizontalPadding,
                vertical: CalendarSizes.itemVerticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final line in lines.take(visibleCount))
                    Text(
                      line.text,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color.withValues(alpha: line.opacity),
                        fontSize: CalendarSizes.itemFontSize,
                        height: CalendarSizes.itemLineHeight,
                        fontWeight: line.weight,
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

class _ItemLine {
  final String text;
  final FontWeight weight;
  final double opacity;

  const _ItemLine(this.text, this.weight, this.opacity);
}
