import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class FieldLabel extends StatelessWidget {
  final String label;

  const FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: AppTextStyles.label,
      ),
    );
  }
}
