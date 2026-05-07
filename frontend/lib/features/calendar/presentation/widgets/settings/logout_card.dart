import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppTheme.background,
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppTheme.error),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
