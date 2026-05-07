import 'package:flutter/material.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/navigation/auth_navigation.dart';
import 'package:frontend/features/auth/presentation/utils/auth_role_labels.dart';
import 'package:frontend/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  final UserProfile profile;

  const RoleSelectionScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Seleccionar modo'),
        backgroundColor: AppTheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${profile.name}',
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el modo en el que deseas ingresar.',
              style: AppTextStyles.screenSubtitle,
            ),
            const SizedBox(height: 28),

            ...profile.roles.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: AppTheme.btnDark,
                  onPressed: () {
                    AuthNavigation.goToRole(
                      context: context,
                      role: role,
                      profile: profile,
                    );
                  },
                  child: Text(AuthRoleLabels.label(role)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
