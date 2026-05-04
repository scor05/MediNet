import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/default_role_service.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  /// Roles disponibles del usuario. Si tiene más de uno se muestra el selector.
  final List<String> roles;

  const SettingsScreen({super.key, this.roles = const []});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _defaultRole;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultRole();
  }

  Future<void> _loadDefaultRole() async {
    final role = await DefaultRoleService.getDefaultRole();
    if (!mounted) return;
    setState(() {
      _defaultRole = role;
      _loading = false;
    });
  }

  Future<void> _onRoleChanged(String? value) async {
    setState(() => _defaultRole = value);
    await DefaultRoleService.setDefaultRole(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value == null
              ? 'Rol predeterminado eliminado'
              : 'Rol predeterminado: ${_roleLabel(value)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _roleLabel(String role) {
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

  Future<void> _logout() async {
    await DefaultRoleService.clear();
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRoleSelector = widget.roles.length > 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── Sección: Rol predeterminado ──
          if (showRoleSelector) ...[
            const Text(
              'Rol predeterminado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecciona el rol con el que quieres iniciar sesión automáticamente.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              color: AppTheme.background,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String?>(
                        value: _defaultRole,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.swap_horiz,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        hint: const Text('Ninguno (mostrar selección)'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Ninguno (mostrar selección)'),
                          ),
                          ...widget.roles.map(
                            (role) => DropdownMenuItem<String?>(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          ),
                        ],
                        onChanged: _onRoleChanged,
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Sección: Cerrar sesión ──
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            color: AppTheme.background,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.error),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: _logout,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
