import 'package:flutter/material.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';

typedef CreateClinicCallback =
    Future<Clinic> Function({
      required String name,
      required String address,
      required String phone,
      required String email,
    });

class AddClinicDialog extends StatefulWidget {
  final Clinic? initialClinic;
  final CreateClinicCallback onSubmit;

  const AddClinicDialog({super.key, required CreateClinicCallback onCreate})
    : initialClinic = null,
      onSubmit = onCreate;

  const AddClinicDialog.edit({
    super.key,
    required Clinic clinic,
    required CreateClinicCallback onSave,
  }) : initialClinic = clinic,
       onSubmit = onSave;

  @override
  State<AddClinicDialog> createState() => _AddClinicDialogState();
}

class _AddClinicDialogState extends State<AddClinicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  bool get _isEditing => widget.initialClinic != null;

  @override
  void initState() {
    super.initState();
    final clinic = widget.initialClinic;
    if (clinic == null) return;

    _nameController.text = clinic.name;
    _addressController.text = clinic.address;
    _phoneController.text = clinic.phone;
    _emailController.text = clinic.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = _isEditing
              ? 'No se pudo actualizar la clínica.'
              : 'No se pudo crear la clínica.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo requerido' : null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;

    final email = value!.trim();
    if (!email.contains('@') ||
        !email.substring(email.indexOf('@')).contains('.')) {
      return 'Correo inválido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar clínica' : 'Agregar clínica'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                  onFieldSubmitted: (_) {
                    if (!_isSubmitting) _submit();
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
