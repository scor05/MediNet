import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/error_banner.dart';
import 'package:frontend/features/auth/presentation/navigation/auth_navigation.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/utils/auth_validators.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_layout.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;

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

    await ref
        .read(authNotifierProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  void _togglePasswordVisibility() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        AuthNavigation.goAfterRegister(context: context, profile: next.profile);

        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    return AuthLayout(
      title: 'Crear cuenta',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null) ...[
              ErrorBanner(message: error),
              const SizedBox(height: 16),
            ],

            AuthTextField(
              controller: _nameCtrl,
              label: 'Nombre completo',
              hintText: 'Juan Pérez',
              icon: Icons.person_outline,
              validator: AuthValidators.fullName,
            ),

            const SizedBox(height: 20),

            AuthTextField(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              hintText: 'correo@ejemplo.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),

            const SizedBox(height: 20),

            AuthTextField(
              controller: _phoneCtrl,
              label: 'Teléfono',
              hintText: '+502 1234 5678',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: AuthValidators.phone,
            ),

            const SizedBox(height: 20),

            AuthTextField(
              controller: _passwordCtrl,
              label: 'Contraseña',
              hintText: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscure,
              validator: AuthValidators.registerPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),

            const SizedBox(height: 32),

            AuthSubmitButton(
              label: 'Registrarse',
              isLoading: isLoading,
              onPressed: _handleRegister,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Volver a ',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                GestureDetector(
                  onTap: isLoading ? null : () => Navigator.pop(context),
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
    );
  }
}
