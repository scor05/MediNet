import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminClientHeader extends StatelessWidget {
  final String clientName;
  final VoidCallback onAddUser;

  const AdminClientHeader({
    super.key,
    required this.clientName,
    required this.onAddUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Organización',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              clientName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resumen de usuarios asociados a tu organización.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: AppTheme.btnDark,
                onPressed: onAddUser,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar usuario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
