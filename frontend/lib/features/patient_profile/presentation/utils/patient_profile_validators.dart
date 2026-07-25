class PatientProfileValidators {
  const PatientProfileValidators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }

    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }

  static String? phone(String? value) {
    // El teléfono es opcional; solo se valida si el usuario escribió algo
    if (value != null && value.trim().isNotEmpty && value.trim().length < 6) {
      return 'Ingresa un teléfono válido';
    }

    return null;
  }
}
