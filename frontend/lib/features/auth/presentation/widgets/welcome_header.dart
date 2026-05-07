import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/wave_blob.dart';
import 'package:frontend/core/widgets/wave_clipper.dart';
import 'package:frontend/theme/app_theme.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  const Positioned(
                    top: -10,
                    left: -20,
                    child: WaveBlob(size: 90),
                  ),
                  const Positioned(
                    top: 10,
                    right: 20,
                    child: WaveBlob(size: 60),
                  ),
                  const Positioned(
                    top: 60,
                    left: 40,
                    child: WaveBlob(size: 40),
                  ),
                  const Positioned(
                    top: 80,
                    right: -10,
                    child: WaveBlob(size: 70),
                  ),
                  const Positioned(
                    top: 140,
                    left: 10,
                    child: WaveBlob(size: 50),
                  ),
                  const Positioned(
                    top: 180,
                    right: 60,
                    child: WaveBlob(size: 35),
                  ),
                  const Positioned(
                    top: 160,
                    left: 160,
                    child: WaveBlob(size: 55),
                  ),
                  const Positioned(
                    bottom: 60,
                    left: -15,
                    child: WaveBlob(size: 80),
                  ),
                  const Positioned(
                    bottom: 80,
                    right: 30,
                    child: WaveBlob(size: 45),
                  ),
                  const Positioned(
                    bottom: 100,
                    left: 80,
                    child: WaveBlob(size: 30),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: -10,
                    child: WaveBlob(size: 85),
                  ),
                  const Positioned(
                    bottom: 140,
                    left: -5,
                    child: WaveBlob(size: 60),
                  ),
                  const Positioned(
                    bottom: 30,
                    left: 70,
                    child: WaveBlob(size: 35),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'MEDINET',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Bienvenido',
                        style: TextStyle(
                          color: AppColors.background,
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
    );
  }
}
