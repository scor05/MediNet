import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: AppTheme.btnDark,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.textInverse,
                strokeWidth: 2.5,
              ),
            )
          : Text(label),
    );
  }
}
