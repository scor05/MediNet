import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class SearchPlaceholder extends StatelessWidget {
  const SearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Selecciona un doctor o una clínica para ver disponibilidad.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
