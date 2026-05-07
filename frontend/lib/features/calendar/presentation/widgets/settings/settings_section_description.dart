import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class SettingsSectionDescription extends StatelessWidget {
  final String text;

  const SettingsSectionDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
    );
  }
}
