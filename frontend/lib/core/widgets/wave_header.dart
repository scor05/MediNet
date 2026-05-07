import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/wave_blob.dart';
import 'package:frontend/core/widgets/wave_clipper.dart';
import 'package:frontend/theme/app_theme.dart';

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
                const Positioned(
                  top: -10,
                  left: -20,
                  child: WaveBlob(size: 90),
                ),
                const Positioned(top: 10, right: 20, child: WaveBlob(size: 60)),
                const Positioned(top: 60, left: 40, child: WaveBlob(size: 40)),
                const Positioned(
                  top: 80,
                  right: -10,
                  child: WaveBlob(size: 70),
                ),
                const Positioned(top: 120, left: 10, child: WaveBlob(size: 35)),
                const Positioned(top: 40, left: 160, child: WaveBlob(size: 50)),

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

                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
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
