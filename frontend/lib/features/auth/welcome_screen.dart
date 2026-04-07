import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
//temporarl en lo que hago cada pantalla
//import 'package:frontend/features/auth/login_screen.dart';
//import 'package:frontend/features/auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
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
                        // circulos decorativos
                        Positioned(top: -10, left: -20, child: _Blob(size: 90)),
                        Positioned(top: 10, right: 20, child: _Blob(size: 60)),
                        Positioned(top: 80, right: -10, child: _Blob(size: 70)),
                        Positioned(top: 60, left: 40, child: _Blob(size: 40)),
                        Positioned(top: 80, right: -10, child: _Blob(size: 70)),
                        Positioned(top: 140, left: 10, child: _Blob(size: 50)),
                        Positioned(
                          bottom: 100,
                          left: 80,
                          child: _Blob(size: 30),
                        ),
                        Positioned(
                          bottom: 60,
                          left: -15,
                          child: _Blob(size: 80),
                        ),
                        Positioned(top: 160, left: 160, child: _Blob(size: 55)),

                        // Contenido centrado
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            const Text(
                              'MEDINET',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Bienvenido',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: _WaveClipper(),
                    child: Container(height: 60, color: AppTheme.background),
                  ),
                ),
              ],
            ),
          ),

          // Botones — fondo independiente del header
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
            child: Column(
              children: [
                ElevatedButton(
                  style: AppTheme.btnDark,

                  ///solo en lo que termino de hace las otras pantallas
                  onPressed: null,
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: AppTheme.btnLight,
                  onPressed: null,
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

class _Blob extends StatelessWidget {
  final double size;
  const _Blob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(38),
      ),
    );
  }
}

// Esta clase también debe estar en el mismo archivo
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
