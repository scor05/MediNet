import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/session_restoration_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionGate extends ConsumerWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoredHome = ref.watch(restoredSessionHomeProvider);

    return restoredHome.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      data: (home) => home,
      error: (error, _) => _SessionRestorationError(
        onRetry: () => ref.invalidate(restoredSessionHomeProvider),
        onStartOver: () async {
          try {
            await Supabase.instance.client.auth.signOut();
          } finally {
            ref.invalidate(restoredSessionHomeProvider);
          }
        },
      ),
    );
  }
}

class _SessionRestorationError extends StatelessWidget {
  final VoidCallback onRetry;
  final Future<void> Function() onStartOver;

  const _SessionRestorationError({
    required this.onRetry,
    required this.onStartOver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No se pudo restaurar tu sesión.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu sesión guardada no fue eliminada. Revisa tu conexión '
                  'e intenta nuevamente.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => onStartOver(),
                  child: const Text('Cerrar sesión y volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
