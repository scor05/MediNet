import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminEmptyUsersView extends StatelessWidget {
  const AdminEmptyUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.people_outline, size: 48, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'No hay usuarios asociados a esta organización.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
