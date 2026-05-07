import 'package:flutter/material.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/theme/admin_theme.dart';
import 'package:frontend/theme/app_theme.dart';

class UserTile extends StatelessWidget {
  final ClientUser user;
  final VoidCallback onDelete;

  const UserTile({super.key, required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final initial = user.user.name.isNotEmpty
        ? user.user.name[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: AdminTextStyles.chip.copyWith(color: AppTheme.accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.user.name,
                  style: AdminTextStyles.tileTitle,
                ),
                Text(
                  user.user.email,
                  style: AdminTextStyles.tileSubtitle,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role,
              style: AdminTextStyles.badge.copyWith(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: AdminColors.error,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
