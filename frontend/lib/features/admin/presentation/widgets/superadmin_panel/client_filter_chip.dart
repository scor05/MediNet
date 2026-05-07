import 'package:flutter/material.dart';
import 'package:frontend/theme/admin_theme.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ClientFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AdminColors.selected : AppColors.transparent,
          border: Border.all(
            color: selected ? AdminColors.selected : AdminColors.iconMuted,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AdminTextStyles.chip.copyWith(
            color: selected ? AdminColors.selectedText : AdminColors.mutedText,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
