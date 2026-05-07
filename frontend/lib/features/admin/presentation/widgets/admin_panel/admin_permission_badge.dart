import 'package:flutter/material.dart';
import 'package:frontend/theme/admin_theme.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminPermissionBadge extends StatelessWidget {
  final bool isAdmin;

  const AdminPermissionBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final color = isAdmin ? AppTheme.accent : AppTheme.textSecondary;
    final background = isAdmin
        ? AppTheme.accent.withValues(alpha: 0.10)
        : AdminColors.disabledFill;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isAdmin ? 'Admin: Sí' : 'Admin: No',
        style: AdminTextStyles.badge.copyWith(
          color: color,
        ),
      ),
    );
  }
}
