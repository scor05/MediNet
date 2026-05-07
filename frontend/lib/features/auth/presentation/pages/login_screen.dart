import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/error_banner.dart';
import 'package:frontend/features/auth/presentation/navigation/auth_navigation.dart';
import 'package:frontend/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/utils/auth_validators.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_layout.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/theme/app_theme.dart';

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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authNotifierProvider.notifier)
        .login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
  }

  void _togglePasswordVisibility() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) async {
      if (next is AuthAuthenticated) {
        await AuthNavigation.goAfterLogin(
          context: context,
          profile: next.profile,
        );

        ref.read(authNotifierProvider.notifier).reset();
      }

      if (next is AuthSuperadmin) {
        AuthNavigation.goToSuperadmin(context);
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    return AuthLayout(
      title: 'Login',
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
              controller: _emailCtrl,
              label: 'Correo electrónico',
              hintText: 'correo@ejemplo.com',
              icon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),

            const SizedBox(height: 20),

            AuthTextField(
              controller: _passwordCtrl,
              label: 'Contraseña',
              hintText: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscure,
              validator: AuthValidators.loginPassword,
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
              label: 'Iniciar sesión',
              isLoading: isLoading,
              onPressed: _handleLogin,
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: AppTheme.btnLight,
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
              child: const Text('Registro'),
            ),
          ],
        ),
      ),
    );
  }
}
