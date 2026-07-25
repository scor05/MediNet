import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/error_banner.dart';
import 'package:frontend/core/widgets/wave_header.dart';
import 'package:frontend/features/patient_profile/domain/entities/patient_profile.dart';
import 'package:frontend/features/patient_profile/domain/providers/patient_domain_providers.dart';
import 'package:frontend/features/patient_profile/presentation/utils/patient_profile_validators.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:frontend/theme/app_theme.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  String? _saveError;

  // Inicializa los controladores con los datos del perfil cargado
  void _populateControllers(PatientProfile profile) {
    _nameCtrl.text = profile.name;
    _phoneCtrl.text = profile.phone;
  }

  // Cancela la edición y restaura los valores originales
  void _cancelEditing(PatientProfile profile) {
    _formKey.currentState?.reset();
    _populateControllers(profile);
    setState(() {
      _isEditing = false;
      _saveError = null;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await ref.read(patientProfileNotifierProvider.notifier).updateProfile(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          );

      if (!mounted) return;

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Perfil actualizado correctamente'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(patientProfileNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          WaveHeader(title: 'Mi Perfil', showBack: true),
          Expanded(
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () =>
                    ref.invalidate(patientProfileNotifierProvider),
              ),
              data: (profile) {
                // Pre-carga los controladores la primera vez que llegan los datos
                // pero no en cada rebuild para no sobreescribir lo que el usuario escribe
                if (!_isEditing &&
                    _nameCtrl.text.isEmpty &&
                    _phoneCtrl.text.isEmpty) {
                  _populateControllers(profile);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Avatar / email header ──────────────────────────
                        _ProfileAvatar(email: profile.email),
                        const SizedBox(height: 32),

                        // ── Mensajes de error al guardar ──────────────────
                        if (_saveError != null) ...[
                          ErrorBanner(message: _saveError!),
                          const SizedBox(height: 16),
                        ],

                        // ── Nombre ────────────────────────────────────────
                        AuthTextField(
                          controller: _nameCtrl,
                          label: 'Nombre completo',
                          hintText: 'Juan Pérez',
                          icon: Icons.person_outline,
                          validator: _isEditing
                              ? PatientProfileValidators.name
                              : (_) => null,
                          keyboardType: TextInputType.name,
                          enabled: _isEditing,
                        ),

                        const SizedBox(height: 20),

                        // ── Correo (siempre read-only) ────────────────────
                        _ReadOnlyField(
                          label: 'Correo electrónico',
                          value: profile.email,
                          icon: Icons.email_outlined,
                          trailing: const Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Teléfono ──────────────────────────────────────
                        AuthTextField(
                          controller: _phoneCtrl,
                          label: 'Teléfono',
                          hintText: '+502 1234 5678',
                          icon: Icons.phone_outlined,
                          validator: _isEditing
                              ? PatientProfileValidators.phone
                              : (_) => null,
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                        ),

                        const SizedBox(height: 36),

                        // ── Acciones ──────────────────────────────────────
                        if (_isEditing) ...[
                          AuthSubmitButton(
                            label: 'Guardar cambios',
                            isLoading: _isSaving,
                            onPressed: _handleSave,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                foregroundColor: AppColors.textSecondary,
                              ),
                              onPressed: _isSaving
                                  ? null
                                  : () => _cancelEditing(profile),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          ElevatedButton(
                            style: AppTheme.btnLight,
                            onPressed: () =>
                                setState(() => _isEditing = true),
                            child: const Text('Editar perfil'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets privados ────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String email;

  const _ProfileAvatar({required this.email});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 40,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(email, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Widget? trailing;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value, style: AppTextStyles.body),
            ),
            ?trailing,
          ],
        ),
        const Divider(
          color: AppColors.subtleBorder,
          height: 16,
          thickness: 1.5,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ErrorBanner(message: message),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppTheme.btnLight,
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
