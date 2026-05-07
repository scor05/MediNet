import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/dialogs/edit_admin_privileges_dialog.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_panel/admin_permission_badge.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminUserCard extends StatelessWidget {
  final int clientId;
  final ClientUser user;

  const AdminUserCard({super.key, required this.clientId, required this.user});

  void _openPermissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => EditAdminPrivilegesDialog(
        clientId: clientId,
        user: user,
        currentIsAdmin: user.isAdmin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = user.user.name.isNotEmpty
        ? user.user.name[0].toUpperCase()
        : '?';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.14),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.user.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.user.email,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _RoleBadge(role: user.role),
                      AdminPermissionBadge(isAdmin: user.isAdmin),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Editar permisos',
              onPressed: () => _openPermissionsDialog(context),
              icon: const Icon(
                Icons.admin_panel_settings_outlined,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  String get _label {
    switch (role) {
      case 'doctor':
        return 'Doctor';
      case 'secretary':
        return 'Secretaria';
      case 'admin':
        return 'Administrador';
      case 'patient':
        return 'Paciente';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
