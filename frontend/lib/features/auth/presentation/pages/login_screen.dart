import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';
import 'package:frontend/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend/features/auth/presentation/pages/role_selection_screen.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/calendar/presentation/pages/doctor_calendar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Inicializa las dependencias
  final _loginUsecase = LoginUsecase(
    AuthRepositoryImpl(AuthRemoteDatasource()),
  );

  final _profileDatasource = ProfileRemoteDatasource();

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  // Limpia los controladores cuando el widget se destruye
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Construye la lista de roles disponibles con base en el perfil
  List<String> _extractRoles(Map<String, dynamic> profile) {
    final roles = <String>[];

    // Se considera paciente como modo base para cualquier usuario autenticado
    roles.add('patient');

    // Agrega rol doctor si aplica
    if (profile['is_doctor'] == true) {
      roles.add('doctor');
    }

    // Agrega rol secretaria si aplica
    if (profile['is_secretary'] == true) {
      roles.add('secretary');
    }

    // Agrega rol administrador si el usuario administra al menos un cliente
    if (profile['admin_of'] is List &&
        (profile['admin_of'] as List).isNotEmpty) {
      roles.add('admin');
    }

    return roles;
  }

  // Navega automáticamente según el rol cuando el usuario solo tiene un modo disponible
  void _navigateSingleRole(BuildContext context, String role) {
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

  // Maneja el inicio de sesión al presionar el botón de login
  Future<void> _handleLogin() async {
    // Si el formulario no es válido, no hace nada
    if (!_formKey.currentState!.validate()) return;

    // Muestra el indicador de carga y limpia el mensaje de error
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Llama al servicio de autenticación
    final result = await _loginUsecase(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    // Si la pantalla ya no existe, no hace nada
    if (!mounted) return;

    // Si el login fue exitoso, consulta el perfil del usuario
    // para determinar los modos disponibles dentro del sistema
    if (result.success) {
      try {
        // Obtiene el perfil del backend usando el token actual de Supabase
        final profile = await _profileDatasource.getProfile();

        // Determina los roles disponibles del usuario
        final roles = _extractRoles(profile);

        // Si la pantalla ya no existe, no hace nada
        if (!mounted) return;

        // Si solo existe un rol disponible, navega automáticamente
        if (roles.length == 1) {
          _navigateSingleRole(context, roles.first);
        } else {
          // Si tiene más de un rol, muestra la pantalla de selección de modo
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RoleSelectionScreen(roles: roles, profile: profile),
            ),
          );
        }
      } catch (e) {
        print('ERROR PROFILE: $e');
        setState(() {
          _error =
              'Inicio de sesión exitoso, pero no se pudo cargar el perfil.';
        });
      }
    } else {
      setState(() => _error = result.error);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                    if (_error != null) ...[
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
                                _error!,
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
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
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
