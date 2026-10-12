import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

/// Rodea un buscador y distingue tres estados: sin texto, texto escrito que
/// todavía no es una selección, y elemento seleccionado de la lista.
///
/// Los keys de los mensajes usan [keyPrefix]: `-selected`, `-hint`,
/// `-typed-hint` y `-clear`.
class SearchSelectionStatus extends StatelessWidget {
  final String keyPrefix;

  /// Texto mostrado cuando hay una selección válida. `null` si no la hay.
  final String? selectedLabel;
  final bool hasTypedText;

  /// Mensaje cuando no hay selección (por ejemplo, "Selecciona un doctor
  /// de la lista").
  final String prompt;

  /// Explicación adicional cuando se escribió texto sin seleccionar.
  final String? typedHint;

  /// Acción para quitar o cambiar lo escrito o seleccionado.
  final VoidCallback? onClear;
  final String clearLabel;
  final Widget child;

  const SearchSelectionStatus({
    super.key,
    required this.keyPrefix,
    required this.selectedLabel,
    required this.hasTypedText,
    required this.prompt,
    required this.child,
    this.typedHint,
    this.onClear,
    this.clearLabel = 'Cambiar',
  });

  @override
  Widget build(BuildContext context) {
    final label = selectedLabel;
    final isSelected = label != null;
    final accent = isSelected
        ? AppColors.success
        : (hasTypedText ? AppColors.warning : AppColors.textSecondary);
    final showAction = onClear != null && (isSelected || hasTypedText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.success.withValues(alpha: 0.08)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: isSelected || hasTypedText
                    ? accent
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: child,
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : (hasTypedText
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline),
              size: 16,
              color: accent,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: isSelected
                  ? Text(
                      label,
                      key: ValueKey('$keyPrefix-selected'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt,
                          key: ValueKey('$keyPrefix-hint'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        if (hasTypedText && typedHint != null)
                          Text(
                            typedHint!,
                            key: ValueKey('$keyPrefix-typed-hint'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
            ),
            if (showAction)
              TextButton(
                key: ValueKey('$keyPrefix-clear'),
                onPressed: onClear,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(clearLabel),
              ),
          ],
        ),
      ],
    );
  }
}
