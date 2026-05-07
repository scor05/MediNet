import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class EditClientDialog extends StatefulWidget {
  final String initialName;
  final String initialNit;
  final Future<void> Function(String name, String nit) onSave;

  const EditClientDialog({
    super.key,
    required this.initialName,
    required this.initialNit,
    required this.onSave,
  });

  @override
  State<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nitCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _nitCtrl = TextEditingController(text: widget.initialNit);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final nit = _nitCtrl.text.trim();

    if (name.isEmpty || nit.isEmpty) return;

    setState(() => _saving = true);

    try {
      await widget.onSave(name, nit);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cliente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: _inputDecoration('Nombre'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nitCtrl,
            decoration: _inputDecoration('NIT'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
          ),
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
