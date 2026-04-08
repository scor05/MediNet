import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/wave_header.dart';

// Temporal en lo que se hacen todas las pantallas
import 'package:frontend/features/auth/presentation/pages/login_screen.dart';
import 'package:frontend/features/auth/presentation/pages/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header con ola
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: AppTheme.accent,
                  child: SafeArea(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Blobs distribuidos por toda la pantalla
                        Positioned(
                          top: -10,
                          left: -20,
                          child: WaveBlob(size: 90),
                        ),
                        Positioned(
                          top: 10,
                          right: 20,
                          child: WaveBlob(size: 60),
                        ),
                        Positioned(
                          top: 60,
                          left: 40,
                          child: WaveBlob(size: 40),
                        ),
                        Positioned(
                          top: 80,
                          right: -10,
                          child: WaveBlob(size: 70),
                        ),
                        Positioned(
                          top: 140,
                          left: 10,
                          child: WaveBlob(size: 50),
                        ),
                        Positioned(
                          top: 180,
                          right: 60,
                          child: WaveBlob(size: 35),
                        ),
                        Positioned(
                          top: 160,
                          left: 160,
                          child: WaveBlob(size: 55),
                        ),
                        Positioned(
                          bottom: 60,
                          left: -15,
                          child: WaveBlob(size: 80),
                        ),
                        Positioned(
                          bottom: 80,
                          right: 30,
                          child: WaveBlob(size: 45),
                        ),
                        Positioned(
                          bottom: 100,
                          left: 80,
                          child: WaveBlob(size: 30),
                        ),
                        Positioned(
                          bottom: 20,
                          left: -10,
                          child: WaveBlob(size: 85),
                        ),
                        Positioned(
                          bottom: 140,
                          left: -5,
                          child: WaveBlob(size: 60),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 70,
                          child: WaveBlob(size: 35),
                        ),

                        // Contenido centrado
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'MEDINET',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Bienvenido',
                              style: TextStyle(
                                color: AppTheme.background,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Ola inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(height: 60, color: AppTheme.background),
                  ),
                ),
              ],
            ),
          ),

          // Botones
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
            child: Column(
              children: [
                ElevatedButton(
                  style: AppTheme.btnDark,
                  // TODO:
                  //falta poner la logica de supabase
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),

                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: AppTheme.btnLight,
                  // TODO: descomentar cuando esté lista RegisterScreen
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
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
