class AuthValidators {
  const AuthValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo';
    }

    if (!value.contains('@')) {
      return 'Correo inválido';
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

    return null;
  }
}
