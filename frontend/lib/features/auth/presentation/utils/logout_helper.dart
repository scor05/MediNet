import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

Future<void> logoutAndGoToWelcome({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  await ref.read(authNotifierProvider.notifier).logout();

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (route) => false,
  );
}
