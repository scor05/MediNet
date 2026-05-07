import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/pages/login_screen.dart';
import 'package:frontend/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend/features/auth/presentation/widgets/welcome_header.dart';
import 'package:frontend/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const WelcomeHeader(),
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
            child: Column(
              children: [
                ElevatedButton(
                  style: AppTheme.btnDark,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: AppTheme.btnLight,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Registro'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
