import 'package:flutter/material.dart';
import 'package:frontend/theme/calendar_theme.dart';

class FabMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FabMenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: CalendarColors.lightShadow,
                blurRadius: CalendarSizes.fabLabelShadowBlur,
              ),
            ],
          ),
          child: Text(label, style: CalendarTextStyles.fabMenuLabel),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(
            icon,
            size: CalendarSizes.fabIconSize,
            color: CalendarColors.textInverse,
          ),
        ),
      ],
    );
  }
}
