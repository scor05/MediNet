import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const AdminOption({
    super.key,
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected && !disabled
              ? AppTheme.accent
              : disabled
              ? Colors.black12
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected && !disabled ? AppTheme.accent : Colors.black26,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected && !disabled
                ? Colors.white
                : disabled
                ? Colors.black38
                : Colors.black54,
          ),
        ),
      ),
    );
  }
}
