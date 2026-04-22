import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/pages/admin_panel.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/calendar/presentation/pages/doctor_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_calendar_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';

class RoleSelectionScreen extends StatelessWidget {
  final UserProfile profile;

  const RoleSelectionScreen({super.key, required this.profile});

  void _navigateByRole(BuildContext context, String role) {
    switch (role) {
      case 'doctor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorCalendarScreen()),
        );
        break;
      case 'secretary':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecretaryCalendarScreen()),
        );
        break;
      case 'admin':
        if (profile.adminOf.isEmpty) return;
        final organization = profile.adminOf.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminPanel(
              clientId: organization.clientId,
              clientName: organization.clientName,
            ),
          ),
        );
        break;
      case 'patient':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientCalendarPage()),
        );
        break;
    }
  }

  String _getRoleLabel(String role) {
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const WaveHeader(title: 'Seleccionar modo', showBack: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${profile.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el modo en el que deseas ingresar.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // profile.roles viene del getter de la entidad
                  ...profile.roles.map(
                    (role) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        style: AppTheme.btnDark,
                        onPressed: () => _navigateByRole(context, role),
                        child: Text(_getRoleLabel(role)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
