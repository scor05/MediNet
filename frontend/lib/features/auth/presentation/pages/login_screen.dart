import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/default_role_service.dart';
import 'package:frontend/features/admin/presentation/pages/admin_panel.dart';
import 'package:frontend/features/admin/presentation/pages/superadmin_panel.dart';
import 'package:frontend/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend/features/auth/presentation/pages/role_selection_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/calendar/presentation/pages/doctor_shell_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/patient_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_shell_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Maneja el login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authNotifierProvider.notifier)
        .login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
  }

  // Navega según los roles cuando el estado pasa a AuthAuthenticated
  Future<void> _handleAuthenticated(AuthAuthenticated authState) async {
    final profile = authState.profile;
    final roles = profile.roles;

    if (roles.length == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PatientCalendarScreen()),
      );
      return;
    }

    // Verificar si hay un rol predeterminado guardado
    final defaultRole = await DefaultRoleService.getDefaultRole();
    if (defaultRole != null && roles.contains(defaultRole)) {
      if (!mounted) return;
      _navigateToRole(defaultRole, profile);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoleSelectionScreen(profile: profile),
      ),
    );
  }

  /// Navega directamente a la pantalla del rol indicado.
  void _navigateToRole(String role, UserProfile profile) {
    Widget destination;
    switch (role) {
      case 'doctor':
        destination = DoctorShellScreen(roles: profile.roles);
        break;
      case 'secretary':
        destination = SecretaryShellScreen(roles: profile.roles);
        break;
      case 'admin':
        if (profile.adminOf.isEmpty) return;
        final org = profile.adminOf.first;
        destination = AdminPanel(clientId: org.clientId, clientName: org.clientName);
        break;
      case 'patient':
        destination = const PatientCalendarScreen();
        break;
      default:
        destination = RoleSelectionScreen(profile: profile);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha cambios de estado para navegar o mostrar errores
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        _handleAuthenticated(next);
        ref.read(authNotifierProvider.notifier).reset();
      }
      if (next is AuthSuperadmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuperadminPanel()),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const WaveHeader(title: 'Login', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const FieldLabel(label: 'Correo electrónico'),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'correo@ejemplo.com',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu correo';
                        if (!v.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Contraseña'),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textSecondary,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        if (v.length < 6) return 'Mínimo 8 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      style: AppTheme.btnDark,
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      style: AppTheme.btnLight,
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Registro'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
