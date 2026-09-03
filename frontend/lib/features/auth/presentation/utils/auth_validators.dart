class AuthValidators {
  const AuthValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido (ej: usuario@dominio.com)';
    }

    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    return null;
  }

  static String? registerPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre';
    }

    if (value.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Ingresa nombre y apellido';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu teléfono';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-().]{7,20}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un teléfono válido (ej: +502 1234 5678)';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'El teléfono debe tener entre 7 y 15 dígitos';
    }

    return null;
  }
}
