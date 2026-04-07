import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';

// TODO: descomentar cuando esté lista
// import 'package:frontend/features/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    // TODO: Adair — conectar Supabase Auth
    // try {
    //   await Supabase.instance.client.auth.signInWithPassword(
    //     email: _emailCtrl.text.trim(),
    //     password: _passwordCtrl.text,
    //   );
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    // } on AuthException catch (e) {
    //   setState(() => _errorMsg = e.message);
    // } finally {
    //   if (mounted) setState(() => _isLoading = false);
    // }

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header con ola — usando WaveHeader de widgets/wave_header.dart
          const WaveHeader(title: 'Login'),

          // Formulario
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email
                    const FieldLabel(label: 'Usuario'),
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

                    // Contraseña
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
                        if (v == null || v.isEmpty)
                          return 'Ingresa tu contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botón LOGIN
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
                          : const Text('LOGIN'),
                    ),

                    const SizedBox(height: 12),

                    // Botón Registro
                    ElevatedButton(
                      style: AppTheme.btnLight,
                      // TTemporal en lo que termino lista RegisterScreen
                      // onPressed: () => Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      // ),
                      onPressed: null,
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
