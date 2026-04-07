import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    // TODO: Adair — conectar Supabase Auth + POST a /api/users
    // try {
    //   await Supabase.instance.client.auth.signUp(
    //     email: _emailCtrl.text.trim(),
    //     password: _passwordCtrl.text,
    //   );
    //   await http.post(
    //     Uri.parse('TU_API_URL/api/users'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'name':     _nameCtrl.text.trim(),
    //       'email':    _emailCtrl.text.trim(),
    //       'password': _passwordCtrl.text,
    //       'phone':    _phoneCtrl.text.trim(),
    //     }),
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
          // Header con ola y botón de regreso
          const WaveHeader(title: 'Crear cuenta'),

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

                    // Nombre
                    const FieldLabel(label: 'Nombre completo'),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Juan Pérez',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu nombre';
                        if (v.trim().split(' ').length < 2)
                          return 'Ingresa nombre y apellido';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Email
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
                          Icons.email_outlined,
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

                    // Teléfono
                    const FieldLabel(label: 'Teléfono'),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: '+502 1234 5678',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Ingresa tu teléfono';
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
                          return 'Ingresa una contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botón REGISTRO
                    ElevatedButton(
                      style: AppTheme.btnDark,
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('REGISTRO'),
                    ),

                    const SizedBox(height: 16),

                    // Link volver a login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Volver a ',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
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
