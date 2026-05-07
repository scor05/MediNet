import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

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
        color: AppColors.textInverse.withAlpha(38),
      ),
    );
  }
}
