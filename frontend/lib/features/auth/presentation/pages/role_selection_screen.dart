import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';
import 'package:frontend/features/calendar/presentation/pages/doctor_calendar_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final List<String> roles;
  final Map<String, dynamic> profile;

  const RoleSelectionScreen({
    super.key,
    required this.roles,
    required this.profile,
  });

  // Navega a la pantalla correspondiente según el rol seleccionado
  void _navigateByRole(BuildContext context, String role) {
    switch (role) {
      case 'doctor':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorCalendarPage()),
        );
        break;

      case 'secretary':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pantalla de secretaria pendiente de implementar'),
          ),
        );
        break;

      case 'admin':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pantalla de administrador pendiente de implementar'),
          ),
        );
        break;

      case 'patient':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pantalla de paciente pendiente de implementar'),
          ),
        );
        break;
    }
  }

  // Traduce el nombre interno del rol a un texto amigable para la UI
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
                    'Hola, ${profile['name'] ?? 'usuario'}',
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

                  // Se genera un botón por cada rol disponible
                  ...roles.map(
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
