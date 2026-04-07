import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/features/auth/welcome_screen.dart';

// Comentados hasta que estén listos:
// import 'package:frontend/features/auth/login_screen.dart';
// import 'package:frontend/features/auth/register_screen.dart';

void main() {
  runApp(const MediNetApp());
}

class MediNetApp extends StatelessWidget {
  const MediNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const WelcomeScreen(),
    );
  }
}
