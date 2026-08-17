import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/user/data/datasources/user_remote_datasource.dart';
import 'package:frontend/theme/app_theme.dart';

/// Provider autodispose que carga la info básica de un paciente por ID
final patientBasicInfoProvider = FutureProvider.autoDispose.family<
  Map<String, dynamic>,
  int
>((ref, patientId) async {
  return UserRemoteDatasource().getPatientBasicInfo(patientId);
});

/// Diálogo que muestra nombre, correo y teléfono de un paciente.
/// Solo disponible para secretarias autorizadas.
class PatientInfoDialog extends ConsumerWidget {
  final int patientId;
  final String patientName;

  const PatientInfoDialog({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(patientBasicInfoProvider(patientId));

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_outline, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              patientName,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: infoAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) {
          final message = e is ApiException
              ? e.message
              : 'No se pudo cargar la información.';
          return _ErrorContent(
            message: message,
            onRetry: () => ref.invalidate(patientBasicInfoProvider(patientId)),
          );
        },
        data: (info) => _InfoContent(info: info),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _InfoContent extends StatelessWidget {
  final Map<String, dynamic> info;

  const _InfoContent({required this.info});

  @override
  Widget build(BuildContext context) {
    final name = info['name'] as String? ?? '—';
    final email = info['email'] as String? ?? '—';
    final phone = info['phone'] as String? ?? '—';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InfoRow(
          icon: Icons.person_outline,
          label: 'Nombre',
          value: name,
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Correo',
          value: email,
          copyable: true,
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Teléfono',
          value: phone.isNotEmpty ? phone : '—',
          copyable: phone.isNotEmpty,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (copyable && value != '—')
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$label copiado'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.copy_outlined,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: const TextStyle(color: AppColors.error, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}
