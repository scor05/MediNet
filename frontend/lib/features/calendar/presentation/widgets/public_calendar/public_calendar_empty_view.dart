import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class PublicCalendarEmptyView extends StatelessWidget {
  const PublicCalendarEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No hay citas disponibles para los filtros seleccionados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
