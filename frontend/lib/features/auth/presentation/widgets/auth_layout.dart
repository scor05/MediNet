import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/wave_header.dart';
import 'package:frontend/theme/app_theme.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;

  const AuthLayout({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          WaveHeader(title: title, showBack: showBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
