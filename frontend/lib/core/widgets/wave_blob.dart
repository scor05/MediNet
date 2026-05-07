import 'package:flutter/material.dart';

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
