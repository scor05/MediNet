import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (onRetry != null) ...[
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
