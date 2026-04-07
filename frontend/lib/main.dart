import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/config/supabase_config.dart';
import 'package:frontend/features/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

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
