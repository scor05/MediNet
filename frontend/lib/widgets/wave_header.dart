import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

// ─── WaveHeader ──────────────────────────────────────────────────────────────
// Header en forma de ola y bolitas decorativas

class WaveHeader extends StatelessWidget {
  final String title;
  final bool showBack;

  const WaveHeader({super.key, required this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          color: AppTheme.accent,
          child: SafeArea(
            child: Stack(
              children: [
                // Blobs decorativos
                Positioned(top: -10, left: -20, child: WaveBlob(size: 90)),
                Positioned(top: 10, right: 20, child: WaveBlob(size: 60)),
                Positioned(top: 60, left: 40, child: WaveBlob(size: 40)),
                Positioned(top: 80, right: -10, child: WaveBlob(size: 70)),
                Positioned(top: 120, left: 10, child: WaveBlob(size: 35)),
                Positioned(top: 40, left: 160, child: WaveBlob(size: 50)),

                // Botón de regreso opcional
                if (showBack)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                // Título centrado
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
            child: Container(height: 50, color: AppTheme.background),
          ),
        ),
      ],
    );
  }
}

// Círculos decorativos semitransparentes usado en los headers

class WaveBlob extends StatelessWidget {
  final double size;
  const WaveBlob({super.key, required this.size});

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

// Genera la forma de ola en la parte inferior del header

class WaveClipper extends CustomClipper<Path> {
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
  bool shouldReclip(WaveClipper oldClipper) => false;
}

// Label de campo de formulario usado en LoginScreen y RegisterScreen

class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
